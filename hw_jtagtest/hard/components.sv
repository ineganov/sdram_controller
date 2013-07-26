//====================================================================//
module ffd #( parameter WIDTH = 32)
            ( input                  CLK, 
              input                  RESET,
              input                  EN,
              input      [WIDTH-1:0] D,
              output reg [WIDTH-1:0] Q );
                 
always_ff @(posedge CLK)
  if (RESET)  Q <= 0;
  else if(EN) Q <= D;

endmodule
//====================================================================//
module ffds #( parameter WIDTH = 32)
             ( input                    CLK, 
               input        [WIDTH-1:0] D,
               output logic [WIDTH-1:0] Q );
                 
always_ff @(posedge CLK)
  Q <= D;

endmodule
//====================================================================//
module mux2 #(parameter WIDTH = 32)
             ( input             S,
               input [WIDTH-1:0] D0,
               input [WIDTH-1:0] D1,
               output[WIDTH-1:0] Y);

assign Y = S ? D1 : D0;

endmodule
//====================================================================//
module mux4 #(parameter WIDTH = 32)
             ( input [1:0] S,
               input [WIDTH-1:0] D0, D1, D2, D3,
               output[WIDTH-1:0] Y);

assign Y = S[1] ? (S[0] ? D3 : D2)
                : (S[0] ? D1 : D0);
                
endmodule
//====================================================================//
module counter #(parameter SIZE = 8) (  input             CLK,
                                        input             RESET,
                                        input             EN,
                                        output [SIZE-1:0] OUT );

logic [SIZE-1:0] cnt;
                                        
always_ff@ (posedge CLK)
  if(RESET)
    cnt <= '0;
  else if(EN) cnt <= cnt + 1'b1;
    
assign OUT = cnt;
                                        
endmodule
//====================================================================//
module inv_counter #(  parameter SIZE      = 8, 
                       parameter ARM_VAL = 100 ) 
                    (  input             CLK,
                       input             RESET,
                       input             ARM,
                       output [SIZE-1:0] OUT );

logic [SIZE-1:0] cnt;
                                        
always_ff@ (posedge CLK)
  if(RESET)    cnt <= '0; //'
  else if(ARM) cnt <= ARM_VAL;
  else if(cnt != '0) //'
               cnt <= cnt - 1'b1;
    
assign OUT = cnt;
                                        
endmodule
//====================================================================//
module sync (  input  CLK,
               input  IN,
               output OUT );
 
reg [1:0] v;

always_ff @(posedge CLK)
  v <= {v[0], IN};

assign OUT = v[1];
               
endmodule
//====================================================================//
module shift_reg_rf #(parameter SIZE = 8) ( input             CLK,
                                            input             RESET,
                                            input             IN,
                                            input             EN,
                                            output [SIZE-1:0] OUT );

//LSB-first shift register

logic [SIZE-1:0] sreg;

always_ff@ (posedge CLK)
  if(RESET)   sreg <= '0; //'
  else if(EN) sreg <= {sreg[SIZE-2:0], IN}; 

assign OUT = sreg;
endmodule
//====================================================================//
module counter_ll #(parameter SIZE = 8) (  input             CLK,
                                           input             RESET,
                                           input             EN,
                                           output [SIZE-1:0] OUT );

logic [SIZE-1:0] cnt, cnt_plus_one;

assign cnt_plus_one = cnt + 1'b1;                                        
always_ff@ (posedge CLK)
  if(RESET)
    cnt <= '0; //'
  else if(EN) cnt <= cnt_plus_one;
    
assign OUT = EN ? cnt_plus_one : cnt;
                                        
endmodule
//====================================================================//
module sreg_delay #(parameter V = 2) (  input  CLK,
                                        input  RESET,
                                        input  IN,
                                        output OUT );

logic [V-1:0] sreg;

always_ff@(posedge CLK)
   if(RESET) sreg <= '0; //'
   else      sreg <= {sreg[V-2:0], IN};

assign OUT = sreg[V-1];
endmodule   
//====================================================================//
module autoreset #(parameter SIZE = 16) ( input  CLK,
                                          input  EXT_RESET,
                                          output RESET );

logic [SIZE-1:0] reset_cnt_q;
assign RESET = (reset_cnt_q != '1); //'
counter #(SIZE) reset_cnt(CLK, EXT_RESET, RESET, reset_cnt_q);

endmodule
//====================================================================//
module s_edetect_p (  input  CLK,
                      input  IN,
                      output POS );
 
logic [2:0] v;

always@(posedge CLK)
  v <= {v[1:0], IN};

assign POS = v[1] & ~v[2];                
endmodule
//====================================================================//
