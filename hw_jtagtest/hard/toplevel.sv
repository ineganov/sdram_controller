module toplevel (    input         CLK,
                     output        SDRAM_CLK,
                     output  [7:0] LEDS,
                     output        CKE,
                     output [12:0] A,
                     output [ 1:0] BA,
                     inout  [15:0] DQ,
                     output        DQML,
                     output        DQMH,
                     output        CSn,
                     output        RASn,
                     output        CASn,
                     output        WEn    );

logic        reset, we, we_len, we_a, busy;
logic [31:0] wd, rd;
logic  [7:0] addr;

autoreset autoreset(CLK, 1'b0, reset);

jtag    jtag( .CLK    ( CLK    ),
              .RESET  ( reset  ),
              .WE     ( we     ),
              .WE_LEN ( we_len ),
              .WE_A   ( we_a   ),
              .ADDR   ( addr   ),
              .WD     ( wd     ),
              .RD     ( rd     ) );

sdram_mac  sdram_mac(  .CLK    ( CLK    ),
                       .RESET  ( reset  ),
                       .ADDR   ( addr   ),
                       .WD     ( wd     ),
                       .RD     ( rd     ),
                       .WE     ( we     ),
                       .WE_LEN ( we_len ),
                       .WE_A   ( we_a   ),
                       .BUSY   ( busy   ),
                       .CKE    ( CKE    ),
                       .A      ( A      ),
                       .BA     ( BA     ),
                       .DQ     ( DQ     ),
                       .DQML   ( DQML   ),
                       .DQMH   ( DQMH   ),
                       .CSn    ( CSn    ),
                       .RASn   ( RASn   ),
                       .CASn   ( CASn   ),
                       .WEn    ( WEn    ));

assign LEDS = addr;
assign SDRAM_CLK = CLK;

endmodule
