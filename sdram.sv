//========================================================================================//
module  sdram( input         CLK,
               input         RESET,
               input   [8:0] LENGTH,  //Length-1 actually. Use 0 to transfer 1 word.
               output  [8:0] MAX_LEN, //maximum length (depends on refresh proximity)
               input  [23:0] ADDR,
               input  [15:0] DATA_IN,
               output [15:0] DATA_OUT,
               input         REQUEST,
               input         WRITE,
               output        BUSY,
               output        WR_ADV,
               output        RD_ADV,
               
               output        CKE,
               output [12:0] A,
               output [ 1:0] BA,
               inout  [15:0] DQ,
               output        DQML,
               output        DQMH,
               output        CSn,
               output        RASn,
               output        CASn,
               output        WEn );

//Refresh period. 64ms for each of the 8192 rows = 7.8 uS period
// -> 390@50MHz, 625@80MHz, 781@100MHz
parameter tREF = 390;

//Refresh operation time. 67.5ns
// -> 4@50MHz, 6@80MHz, 7@100MHz
parameter tRC = 6;

//Precharge time. 20ns
// -> 2@50MHz, 2@80MHz, 3@100MHz
parameter tRP = 2;

//Mode register program time. 15ns
// -> 1@50MHz, 2@80MHz, 2@100MHz
parameter tMRD = 1;

//CAS latency
// Set to 2.
parameter tCAS = 2;

//Row activation time. 20ns
// ->2 @50MHz, 2@80MHz, 3@100MHz;
parameter tRCD = 3;

logic [12:0] addr_l;
logic [15:0] writedata;
logic  [9:0] refresh_cnt;
logic  [8:0] op_cnt;
logic  [2:0] iter_cnt;
logic  [1:0] dqm, ba_l;
logic        s_idle,  s_pchg, s_rfsh, s_rfsh_i, s_active, s_mrs, 
             s_write, s_read, s_term, s_nop, s_write_q, 
             t_done, i_done, fsm_ras, fsm_cas, fsm_we, cmd_time, do_rfsh;

// This inverse counter determines maximum transaction length:
// tREF-10 is a good guess for max_len
inv_counter #(9, 380) inv_counter(CLK, RESET, s_rfsh & t_done, MAX_LEN);


assign do_rfsh = (refresh_cnt == tREF);
counter #(10) refresh_counter(CLK, RESET | do_rfsh, 1'b1, refresh_cnt);

assign cmd_time =  (op_cnt == 0);

assign t_done = ( ((op_cnt == (tRC-1 )) & s_rfsh   ) |
                  ((op_cnt == (tRC-1 )) & s_rfsh_i ) |
                  ((op_cnt == (tRC-1 )) & s_nop    ) |
                  ((op_cnt == (tRP-1 )) & s_pchg   ) |
                  ((op_cnt == (tMRD-1)) & s_mrs    ) |
                  ((op_cnt == (tRCD-1)) & s_active ) |
                  ((op_cnt ==  LENGTH ) & s_read   ) |
                  ((op_cnt ==  LENGTH ) & s_write  ) );

counter  #(9)   op_counter(CLK, RESET | t_done | s_idle | s_term, 1'b1, op_cnt);

assign i_done = (iter_cnt == 3'd7);
counter  #(3) iter_counter(CLK, RESET | (i_done & t_done), (t_done & s_rfsh_i), iter_cnt);


sdram_fsm sdram_fsm( .CLK     ( CLK      ),
                     .RESET   ( RESET    ),
                     .ACT     ( REQUEST  ),
                     .WRITE   ( WRITE    ),
                     .T_DONE  ( t_done   ),   
                     .I_DONE  ( i_done   ),
                     .DO_RFSH ( do_rfsh  ), 
                     .S_IDLE  ( s_idle   ),
                     .S_PCHG  ( s_pchg   ),
                     .S_RFSH  ( s_rfsh   ),
                     .S_RFSH_I( s_rfsh_i ),
                     .S_ACTIVE( s_active ),
                     .S_MRS   ( s_mrs    ),
                     .S_NOP   ( s_nop    ),
                     .S_WRITE ( s_write  ),
                     .S_READ  ( s_read   ),
                     .S_TERM  ( s_term   ),
                     .RAS     ( fsm_ras  ),
                     .CAS     ( fsm_cas  ),
                     .WE      ( fsm_we   ) );

sreg_delay #(4) read_adv_fd(CLK, RESET, s_read, RD_ADV);

assign WR_ADV = s_write;
assign CKE  = 1'b1;
assign BUSY = ~s_idle;
assign CSn  = RESET;
assign dqm  = (s_read | s_write) ? 2'b00 : 2'b11; //WARNING: see if it works for CAS=3

assign addr_l = s_mrs    ? 13'b000000_010_0_111 :
                s_pchg   ? 13'b0_0100_0000_0000 :
                s_active ?           ADDR[21:9] :
                           {4'b0000, ADDR[8:0]} ;

assign ba_l = s_mrs ? 2'b00 : ADDR[23:22];

ffds  #(2)        ba_fds(CLK,  ba_l, BA);
ffds #(13)   address_fds(CLK, addr_l, A);
ffds #(16)  readdata_fds(CLK, DQ, DATA_OUT);
ffds #(17) writedata_fds(CLK, {s_write, DATA_IN}, {s_write_q, writedata});

ffds #(2) dqm_fds(CLK, dqm, {DQML, DQMH} );
ffds #(1) ras_fds(CLK, (cmd_time ? fsm_ras : 1'b1), RASn );
ffds #(1) cas_fds(CLK, (cmd_time ? fsm_cas : 1'b1), CASn );
ffds #(1)  we_fds(CLK, (cmd_time ? fsm_we  : 1'b1), WEn  );

assign DQ = s_write_q ? writedata : 16'hZZZZ;

endmodule
//========================================================================================//
module sdram_fsm( input  CLK,
                  input  RESET,
                  input  ACT,
                  input  WRITE,
                  input  T_DONE,   // Ticks done. Used to measure state continuity 
                  input  I_DONE,   // Iterations done. Used to measure number of iterations
                  input  DO_RFSH, // Time to refresh

                  output S_IDLE,
                  output S_PCHG,
                  output S_RFSH,
                  output S_RFSH_I,
                  output S_ACTIVE,
                  output S_MRS,
                  output S_NOP,
                  output S_WRITE,
                  output S_READ,
                  output S_TERM,

                  output RAS,
                  output CAS,
                  output WE );

enum int unsigned {  ST_NOP,
                     ST_MODE_SET,
                     ST_PRECHARGE_I,
                     ST_REFRESH_I,
                     ST_IDLE,
                     ST_REFRESH,
                     ST_ACTIVE,
                     ST_WRITE,
                     ST_READ,
                     ST_TERMINATE,
                     ST_PRECHARGE } state, next;

always_comb
   case(state)
   ST_NOP:         if( T_DONE )   next = ST_PRECHARGE_I;
                   else           next = state;

   ST_PRECHARGE_I: if( T_DONE )   next = ST_REFRESH_I;
                   else           next = state;

   ST_REFRESH_I:   if( T_DONE &
                       I_DONE )   next = ST_MODE_SET;
                   else           next = state;

   ST_MODE_SET:    if( T_DONE )   next = ST_IDLE;
                   else           next = state;

   ST_IDLE:        if(  DO_RFSH ) next = ST_REFRESH;
                   else if( ACT ) next = ST_ACTIVE;
                   else           next = state;

   ST_ACTIVE:      if( T_DONE )
                   begin
                      if(WRITE)   next = ST_WRITE;
                      else        next = ST_READ;
                   end
                   else           next = state;

   ST_WRITE:       if( T_DONE )   next = ST_TERMINATE;
                   else           next = state;
               
   ST_READ:        if( T_DONE )   next = ST_TERMINATE;
                   else           next = state;

   ST_TERMINATE:                  next = ST_PRECHARGE;

   ST_PRECHARGE:   if( T_DONE )   next = ST_IDLE;
                   else           next = state;

   ST_REFRESH:     if( T_DONE )   next = ST_IDLE;
                   else           next = state;
   endcase

logic [2:0] controls;  //RAS, CAS, WE
always_comb
   case(state)               //RCW
   ST_READ:      controls = 3'b101;
   ST_WRITE:     controls = 3'b100;
   ST_TERMINATE: controls = 3'b110;
   ST_ACTIVE:    controls = 3'b011;
   ST_PRECHARGE: controls = 3'b010;
   ST_REFRESH:   controls = 3'b001;
   ST_REFRESH_I: controls = 3'b001;
   ST_MODE_SET:  controls = 3'b000;
   default:      controls = 3'b111;
   endcase

always_ff@(posedge CLK)
   if(RESET) state <= ST_NOP;
   else      state <= next;

assign S_IDLE   = ( state == ST_IDLE      );
assign S_PCHG   = ( state == ST_PRECHARGE ) || ( state == ST_PRECHARGE_I );
assign S_RFSH   = ( state == ST_REFRESH   );
assign S_RFSH_I = ( state == ST_REFRESH_I );
assign S_ACTIVE = ( state == ST_ACTIVE    );
assign S_MRS    = ( state == ST_MODE_SET  );
assign S_WRITE  = ( state == ST_WRITE     );
assign S_READ   = ( state == ST_READ      );
assign S_NOP    = ( state == ST_NOP       );
assign S_TERM   = ( state == ST_TERMINATE );

assign RAS = controls[2];
assign CAS = controls[1];
assign WE  = controls[0];

endmodule
//========================================================================================//
