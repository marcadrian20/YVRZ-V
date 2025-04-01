`timescale 1ns/1ps
module ImmediateGenerator(input logic  [31:7] instruction,
                          input logic  [2:0]  ImmSrc,
                          output logic [31:0] Immd
                         );

/////////////////////
//|ImmSrc|TYPE    |
//|------|--------|
//| 000  | I-TYPE |
//|------|--------|
//| 001  | S-TYPE |
//|------|--------|
//| 010  | B-TYPE |
//|------|--------|
//| 011  | U-TYPE |
//|------|--------|
//| 100  | J-TYPE |
//|------|--------|
//| 101  | CSR IMM|
//As per specification, immediates are sign extended

    always_comb begin
        case(ImmSrc)
            3'b000: Immd={{21{instruction[31]}},instruction[30:20]};
            3'b001: Immd={{21{instruction[31]}},instruction[30:25],instruction[11:7]};
            3'b010: Immd={{20{instruction[31]}},instruction[7],instruction[30:25],instruction[11:8],1'b0};
            3'b011: Immd={instruction[31:12],12'b0};
            3'b100: Immd={{12{instruction[31]}},instruction[19:12],instruction[20],instruction[30:21],1'b0};
            3'b101: Immd={27'b0,instruction[19:15]}; 
            default: Immd=32'bx;
        endcase
     end
endmodule