module Multiplexer
#(parameter BitCount=32)
(input SEL_LINE,
 input [BitCount-1:0]in_a,in_b,
 output wire [BitCount-1:0]out);
//    MUX2_MUX32 mux(out,in_a,in_b,SEL_LINE);
assign out=(SEL_LINE)?in_a:in_b;
endmodule
