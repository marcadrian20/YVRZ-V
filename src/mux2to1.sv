`timescale 1ns/1ps
module mux2to1 #(parameter WIDTH=8)
                (input logic             SEL,
                 input logic [WIDTH-1:0] in_a,in_b,
                 output logic [WIDTH-1:0] out);
assign out=(SEL)?in_b:in_a;
endmodule
