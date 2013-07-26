//==============================================================//
module buffer_ram_32to16 (  input         CLK,

                            input         CON_WE,
                            input   [7:0] CON_ADDR,
                            input  [31:0] CON_WD,
       
                            input   [8:0] MEM_ADDR,
                            output [15:0] MEM_RD );


logic [1:0][15:0] ram[0:255];
logic [15:0] mem_rd_q;

always_ff@(posedge CLK)
   begin
   if(CON_WE)  ram[CON_ADDR] <= CON_WD;
   mem_rd_q <= ram[MEM_ADDR / 2][MEM_ADDR % 2];
   end

assign MEM_RD = mem_rd_q;

endmodule
//==============================================================//
module buffer_ram_16to32 (  input         CLK,

                            input   [7:0] CON_ADDR,
                            output [31:0] CON_RD,
       
                            input         MEM_WE,
                            input   [8:0] MEM_ADDR,
                            input  [15:0] MEM_WD );


logic [1:0][15:0] ram[0:255];
logic [31:0] con_rd_q;

always_ff@(posedge CLK)
   begin
   if(MEM_WE)  ram[MEM_ADDR / 2][MEM_ADDR % 2] <= MEM_WD;
   con_rd_q <= ram[CON_ADDR];
   end

assign CON_RD = con_rd_q;

endmodule
//==============================================================//
