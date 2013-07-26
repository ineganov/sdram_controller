//====================================================================//
module sdram_mac  (  input         CLK,
                     input         RESET,
                     input   [7:0] ADDR,
                     input  [31:0] WD,
                     output [31:0] RD,
                     input         WE,
                     input         WE_LEN,
                     input         WE_A,
                     output        BUSY,

                     output        CKE,
                     output [12:0] A,
                     output [ 1:0] BA,
                     inout  [15:0] DQ,
                     output        DQML,
                     output        DQMH,
                     output        CSn,
                     output        RASn,
                     output        CASn,
                     output        WEn     );

logic [23:0] addr;
logic [15:0] mem_wd, mem_rd;
logic  [8:0] mem_ra, mem_wa;
logic unsigned [8:0] req_len, max_len;
logic len_ok;

assign len_ok = (req_len <= max_len);

logic request, wr_req, busy, wr_adv, rd_adv;

logic [1:0] fsm_state;
logic       st_idle, st_armed, st_running;

assign BUSY       = ~st_idle;
assign st_idle    = (fsm_state == 2'b00);
assign st_armed   = fsm_state[0];
assign st_running = fsm_state[1];

assign request = st_armed & ~busy & len_ok;

ffd #(10) len_fd(CLK, RESET, WE_LEN, {WD[31], WD[8:0]}, 
                                     {wr_req, req_len} );

ffd #(24) addr_fd(CLK, RESET, WE_A, WD[23:0], addr);

counter_ll #(9) wr_addr_cnt(CLK, RESET | st_armed, wr_adv, mem_wa);
counter    #(9) rd_addr_cnt(CLK, RESET | st_armed, rd_adv, mem_ra);

shift_reg_rf #(2) fsm_reg(CLK, RESET,   (WE_LEN & st_idle), 
                                      ( (WE_LEN  & st_idle ) |
                                        (request & st_armed) |
                                        (~busy & st_running) ), fsm_state );

buffer_ram_32to16 bram_32to16(  .CLK      ( CLK    ),
                                .CON_WE   ( WE     ),
                                .CON_ADDR ( ADDR   ),
                                .CON_WD   ( WD     ),
                                .MEM_ADDR ( mem_wa ),
                                .MEM_RD   ( mem_wd ) );

buffer_ram_16to32 bram_16to32(  .CLK      ( CLK    ),
                                .CON_ADDR ( ADDR   ),
                                .CON_RD   ( RD     ),
                                .MEM_WE   ( rd_adv ),
                                .MEM_ADDR ( mem_ra ),
                                .MEM_WD   ( mem_rd ) );

sdram sdram ( .CLK     ( CLK     ),
              .RESET   ( RESET   ),
              .LENGTH  ( req_len ),
              .MAX_LEN ( max_len ),
              .ADDR    ( addr    ),
              .DATA_IN ( mem_wd  ),
              .DATA_OUT( mem_rd  ),
              .REQUEST ( request ),
              .WRITE   ( wr_req  ),
              .WR_ADV  ( wr_adv  ),
              .RD_ADV  ( rd_adv  ),
              .BUSY    ( busy    ),
              .CKE     ( CKE     ),
              .A       ( A       ),
              .BA      ( BA      ),
              .DQ      ( DQ      ),
              .DQML    ( DQML    ),
              .DQMH    ( DQMH    ),
              .CSn     ( CSn     ),
              .RASn    ( RASn    ),
              .CASn    ( CASn    ),
              .WEn     ( WEn     ) );

endmodule
