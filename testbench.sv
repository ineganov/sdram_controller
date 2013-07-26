module sdram_mac_tb;  

logic [31:0] WD, RD;
logic  [7:0] ADDR;
logic        CLK, RESET, WE, WE_LEN, WE_A, BUSY;


logic [12:0] A;
logic [ 1:0] BA;
wire  [15:0] DQ;
logic        CKE, DQML, DQMH, CSn, RASn, CASn, WEn;

logic [15:0] dq_data1, dq_data2;
logic        dq_drv1, dq_drv2;


task wr_word(input [31:0] W);
  begin
  WD = W;
  @(posedge CLK) WE = 1;
  @(posedge CLK) WE = 0;
  ADDR = ADDR + 1;
  end
endtask

task wr_len( input [8:0] L, 
             input DO_WRITE );
  begin
  WD = {DO_WRITE, 22'd0, L};
  @(posedge CLK) WE_LEN = 1;
  @(posedge CLK) WE_LEN = 0;
  end
endtask

task wr_addr(input [31:0] W);
  begin
  WD = W;
  @(posedge CLK) WE_A = 1;
  @(posedge CLK) WE_A = 0;
  end
endtask

always
  begin
  #10ns;
  CLK = ~CLK;
  end

always@(posedge CLK)
  begin
  if({RASn, CASn, WEn} == 3'b101) dq_drv1 <= 1'b1;
  else if(DQMH)                   dq_drv1 <= 1'b0;

  if(dq_drv1) dq_data1 <= dq_data1 + 1;

  dq_data2 <= dq_data1;
  dq_drv2  <= dq_drv1;
  end

initial
  begin
  CLK    = 0;
  RESET  = 1;
  ADDR   = 0;
  WE     = 0;
  WE_LEN = 0;
  WE_A   = 0;
  WD     = 0;
  dq_drv1 = 0;
  dq_drv2 = 0;
  dq_data1 = 0;
  dq_data2 = 0;
  #100ns;
  RESET = 0;
  
  #20ns;
  wr_word(32'h0002_0001);
  wr_word(32'h0004_0003);
  wr_word(32'h0006_0005);
  wr_word(32'h0008_0007);
  wr_addr(32'h0000_0010);
  wr_len (9'd7, 1);

  @(negedge BUSY)  #20ns;
  wr_addr(32'h0000_0010);
  wr_len (9'd7, 0);

  @(negedge BUSY)  #20ns;
  wr_addr(32'h0000_0020);
  wr_len (9'd7, 0);

  @(negedge BUSY)  #20ns;
  wr_addr(32'h0000_0040);
  wr_len (9'd0, 0);

  end

assign DQ = dq_drv2 ? dq_data2 : 16'hZZZZ;

sdram_mac uut(.*);

endmodule
