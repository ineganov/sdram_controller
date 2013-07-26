// Virtual JTAG module
// 
// The module consists of 3 register chains + bypass (ergo 2 bit jtag instructions)
//--------------------------------------------------------------------------------//
// chain 1: control, L=3bit 
// { WE_LEN, WE_A, WE}
// used to enable write strobes
//--------------------------------------------------------------------------------//
// chain 2: current addr L = 8 bit
//--------------------------------------------------------------------------------//
// chain 3: DATA READ/WRITE L = 32 bit
// strobes WE, WE_LEN, WE_A if any enabled in chain 1
//--------------------------------------------------------------------------------//


module jtag    (  input         CLK,
                  input         RESET,

                  output        WE,
                  output        WE_LEN,
                  output        WE_A,

                  output  [7:0] ADDR,
                  output [31:0] WD,
                  input  [31:0] RD );

logic [1:0] INST, inst_q;

// This data is read during scan chain select.
// If you don't see value '1', something is
// seriously wrong with JTAG setup.
wire  [1:0] INST_READOUT = 2'b01;

logic TCK, TDI, TDO;
logic TDO_ctrl, TDO_addr, TDO_data, TDO_bypass; 
logic EN_ctrl, EN_addr, EN_data;
logic ST_CAPTURE_DATA, ST_SHIFT_DATA, ST_UPDATE_DATA, ST_UPDATE_INST; 
logic sync_update;

logic [2:0] controls;
logic [7:0] addr_j;

vji   virtual_jtag (  .tck    ( TCK                ),
                      .tdo    ( TDO                ),
                      .tdi    ( TDI                ),
                      .ir_out ( INST_READOUT       ),
                      .ir_in  ( INST               ),

                      .virtual_state_cdr  ( ST_CAPTURE_DATA  ),
                      .virtual_state_sdr  ( ST_SHIFT_DATA    ),
                      .virtual_state_udr  ( ST_UPDATE_DATA   ),
                      .virtual_state_uir  ( ST_UPDATE_INST   ));

ffd #(2) inst_reg(TCK, RESET, ST_UPDATE_INST, INST, inst_q);
assign EN_ctrl = (inst_q == 2'd1);
assign EN_addr = (inst_q == 2'd2);
assign EN_data = (inst_q == 2'd3);

                  
bypass_chain bypass (TCK, TDI, TDO_bypass);

scan_chain #(3)  ctrl_chain(  .TCK     ( TCK                ),
                              .TDI     ( TDI                ),
                              .TDO     ( TDO_ctrl           ),
                              .EN      ( EN_ctrl            ),
                              .CAPTURE ( ST_CAPTURE_DATA    ),
                              .SHIFT   ( ST_SHIFT_DATA      ),
                              .UPDATE  ( ST_UPDATE_DATA     ),
                              .IN      ( controls           ), 
                              .OUT     ( controls           ));

scan_chain  #(8) addr_chain(  .TCK     ( TCK                ),
                              .TDI     ( TDI                ),
                              .TDO     ( TDO_addr           ),
                              .EN      ( EN_addr            ),
                              .CAPTURE ( ST_CAPTURE_DATA    ),
                              .SHIFT   ( ST_SHIFT_DATA      ),
                              .UPDATE  ( ST_UPDATE_DATA     ),
                              .IN      ( addr_j             ), 
                              .OUT     ( addr_j             ));

scan_chain #(32) data_chain(  .TCK     ( TCK                ),
                              .TDI     ( TDI                ),
                              .TDO     ( TDO_data           ),
                              .EN      ( EN_data            ),
                              .CAPTURE ( ST_CAPTURE_DATA    ),
                              .SHIFT   ( ST_SHIFT_DATA      ),
                              .UPDATE  ( ST_UPDATE_DATA     ),
                              .IN      ( RD                 ),
                              .OUT     ( WD                 ));


ffd #(8) addr_fd(CLK, RESET, 1'b1, addr_j, ADDR);
s_edetect_p (CLK, ST_UPDATE_DATA, sync_update);

assign WE_LEN = sync_update & controls[2] & EN_data;
assign WE_A   = sync_update & controls[1] & EN_data;
assign WE     = sync_update & controls[0] & EN_data;

mux4 #(1) tdo_mux(inst_q, TDO_bypass,
                          TDO_ctrl,
                          TDO_addr,
                          TDO_data,
                          TDO );

endmodule

//=========================================================================//
module bypass_chain ( input      TCK,
                      input      TDI,
                      output reg TDO );

always_ff @(posedge TCK)
   TDO <= TDI;
endmodule
//=========================================================================//
module scan_chain #(parameter SIZE = 8) ( input TCK,
                                          input TDI,
                                          output TDO,
                           
                                          input EN,
                                          input CAPTURE,
                                          input SHIFT,
                                          input UPDATE,
                           
                                          input  [SIZE-1:0] IN,
                                          output [SIZE-1:0] OUT );

logic [SIZE-1:0] sreg, oreg;

always_ff @(posedge TCK)
   if(EN)
      begin
      if(CAPTURE)    sreg <= IN;
      else if(SHIFT) sreg <= { TDI, sreg[SIZE-1:1]};
      end

always_ff @(posedge UPDATE)
   if(EN) oreg <= sreg;

assign OUT = oreg;
assign TDO = sreg[0];

endmodule
//=========================================================================//
module read_chain #(parameter SIZE = 8) ( input            TCK,
                                          input            TDI,
                                          output           TDO,
                                       
                                          input            EN,
                                          input            CAPTURE,
                                          input            SHIFT,
                                       
                                          input [SIZE-1:0] IN );

logic [SIZE-1:0] sreg;

always_ff @(posedge TCK)
   if(EN)
      begin
      if(CAPTURE)    sreg <= IN;
      else if(SHIFT) sreg <= {TDI, sreg[SIZE-1:1]};
      end

assign TDO = sreg[0];

endmodule
//=========================================================================//
