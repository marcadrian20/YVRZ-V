`timescale 1ns/1ps
module mux3to1 #(parameter WIDTH=8)
                (input logic [1:0]       SEL,
                 input logic [WIDTH-1:0] in_a,in_b,in_c,in_d,
                 output logic [WIDTH-1:0] out);
// assign out=(SEL[1])?in_c:(SEL[0])?in_b:in_a;
assign out=(SEL==2'b00)?in_a:(SEL==2'b01)?in_b:(SEL==2'b10)?in_c:in_d;// migth use less LUTs

endmodule