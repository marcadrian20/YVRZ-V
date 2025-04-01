//module CompressedDecoder(input  logic [15:0] compressed_instruction,
//                         output logic [31:0] instruction,
//                         output logic invalid_comp_instr);

//    logic [1:0] op;
//    logic [2:0] func3;
    ///////////////////////////////////////////////////////////
    //xxxxxxxxxxxxxxaa||a!=11, 16 bit instr are only 00,01,10//
    ///////////////////////////////////////////////////////////
//    assign op = compressed_instruction[1:0];
//    assign func3 = compressed_instruction[15:13];
//endmodule