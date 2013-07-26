module sdram_tb;

logic        CLK, RESET, REQUEST, WRITE, BUSY, CKE, WR_ADV, RD_ADV,
             DQML, DQMH, CSn, CASn, RASn, WEn;
logic [15:0] DATA_IN, DATA_OUT;
logic [23:0] ADDR;
logic [12:0] A;
logic [ 8:0] LENGTH, MAX_LEN;
logic [ 1:0] BA;
wire  [15:0] DQ;

always
   begin
   #10ns;
   CLK = ~CLK;
   end

initial
   begin
   LENGTH  = 0;
   CLK     = 0;
   RESET   = 1;
   REQUEST = 0;
   WRITE   = 0;
   DATA_IN = 32'h00000000;
   ADDR    = 24'h00425B;
   #90ns;
   RESET   = 0;

   @(negedge BUSY) #80ns;
   @(posedge CLK) REQUEST = 1;
   @(posedge CLK) REQUEST = 0;


   @(negedge BUSY) #80ns;
   LENGTH = 8;
   WRITE = 1;
   @(posedge CLK) REQUEST = 1;
   @(posedge CLK) REQUEST = 0;
   end


sdram uut(.*);

endmodule
