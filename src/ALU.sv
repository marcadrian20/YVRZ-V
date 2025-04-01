`timescale 1ns/1ps
module alu(input logic clk,reset,
           input logic [31:0] srcA, srcB,
           input logic [3:0] aluOP,
           input logic [2:0] mul_div_func,
           input logic mul_div_op,
           output logic ALUbusy,
           output logic [31:0] aluRESULT)/*synthesis syn_dspstyle = "dsp" */; 

//    logic overflow;
//    assign zero=~(|aluRESULT);
    // assign zero=aluRESULT==32'b0;
//    assign overflow=
logic [31:0] add_sub_op, shiftL, shiftR, shiftRA, and_op, or_op, xor_op,mult_op;/*synthesis syn_dspstyle = "dsp" */
logic LessThan,LessThanSigned/*synthesis syn_dspstyle = "dsp" */;
    assign add_sub_op=aluOP[0]?srcA-srcB:srcA+srcB;
    assign shiftL=srcA<<srcB[4:0];
    assign shiftR=srcA>>srcB[4:0];
    assign shiftRA=$signed(srcA)>>>srcB[4:0];
    assign and_op=srcA&srcB;
    assign or_op=srcA|srcB;
    assign xor_op=srcA^srcB;
    assign LessThan=srcA<srcB;
    assign LessThanSigned=$signed(srcA)<$signed(srcB);
////////////GENEREAL M EXTENSION REGS/////////////
logic [32:0] srcA_reg,srcB_reg;
////////////////////////MULTIPLIER///////
typedef enum logic [1:0] {IDLE,MULT,FINISH} mult_state_t;
mult_state_t mult_state,next_mult_state;
logic [31:0] mult_result;
logic [65:0] mult_result_reg;
logic mult_busy;
logic mult_assert_busy;
assign mult_assert_busy=(!mult_busy&&mul_div_op==1'b1&&!div_busy)||(mult_state==MULT);
always_ff @(posedge clk) begin
    if(reset) begin
        mult_state<=IDLE;
        next_mult_state<=IDLE;
//        mult_result<=32'b0;
        mult_result_reg<=66'b0;
        srcA_reg<=33'b0;
        srcB_reg<=33'b0;
        // ALUbusy<=1'b0;
        mult_busy<=1'b0;
    end
    else begin
        // mult_state<=next_mult_state;    
        case(mult_state)//#TODO modify for dadda or array multiplier !!!#TODO since i stall the pipeline maybe i can simply skip IDLE reg prep?
            IDLE: begin //setup registers or do nothing
                if(mul_div_op&&!mul_div_func[2]) begin 
                    case(mul_div_func[1:0])
                        2'b00,2'b01: begin
                           srcA_reg<={srcA[31],srcA};
                            srcB_reg<={srcB[31],srcB}; 
                        end
                        2'b10: begin
                            srcA_reg<={srcA[31],srcA};
                            srcB_reg<={1'b0,srcB};
                        end
                        2'b11: begin
                            srcA_reg<={1'b0,srcA};
                            srcB_reg<={1'b0,srcB};
                        end
                    endcase
                    // ALUbusy<=1'b1;
                    mult_state<=MULT; 
                    mult_busy<=1'b1;
                end
                else begin 
                   mult_busy<=1'b0;
                    // ALUbusy<=1'b0;
                end
            end
            MULT: begin//begin and multiply
                mult_result_reg<=$signed(srcA_reg)*$signed(srcB_reg);
                mult_state<=FINISH;
                // ALUbusy<=1'b1;
            end
            FINISH: begin //write result
                // case(mul_div_func)
                //     3'b000: mult_result<=mult_result_reg[31:0];
                //     3'b001,3'b010,3'b011: mult_result<=mult_result_reg[63:32];
                // endcase
                mult_state<=IDLE;
                
                // ALUbusy<=1'b0;
            end
            default: mult_state<=IDLE;
        endcase
    end
end    
always_comb begin
    case(mul_div_func)
        3'b000: mult_result=mult_result_reg[31:0];
        3'b001,3'b010,3'b011: mult_result=mult_result_reg[63:32];
        default: mult_result=32'b0;
    endcase
end
//////////////////////////////////////////////////////
////////////////DIVISION SRT RADIX-4////////////////////////#TODO modify for goldschmidt
typedef enum logic [1:0] {DIV_IDLE,DIV_COMPUTE,DIV_FINISH} div_state_t;
div_state_t div_state;
logic [31:0] div_result,div_quotient,srcB_reg_div,div_remainder;
logic [31:0] abs_srcA,abs_srcB;
logic [32:0] q_digit_mul_div;
logic [64:0]div_partial_remainder,div_partial_remainder_shift;
logic [2:0] quotient_digit;
logic [4:0] srcB_lzc,div_counter;
logic div_busy,div_assert_busy;
logic div_result_sign,dividend_sign;
assign abs_srcA=(!mul_div_func[0]&&srcA[31])?-srcA:srcA;
assign abs_srcB=(!mul_div_func[0]&&srcB[31])?-srcB:srcB;
assign div_assert_busy=(!div_busy&&mul_div_op==1'b1&&!mult_busy)||(div_state==DIV_COMPUTE);
leading_zero_count lz_count(.src(abs_srcB),.count(srcB_lzc));
SRTlut SRT_LUT(.b(srcB_reg_div[31:28]),.p(div_partial_remainder[64:59]),.q(quotient_digit));
assign ALUbusy=mult_assert_busy|div_assert_busy;
assign div_partial_remainder_shift=div_partial_remainder[64:0]<<2;
// logic [32:0] div_reminder_temp_shift;
// assign div_reminder_temp_shift=(div_partial_remainder[64:32]+srcB_reg_div)>>srcB_lzc;
logic logictesterif1,logictesterif2;
always_ff @(posedge clk) begin
    if(reset) begin
        div_state<=DIV_IDLE;
        // div_result<=32'b0;
        div_quotient<=32'b0;

        div_remainder<=32'b0;
        div_partial_remainder<=65'b0;
        dividend_sign<=1'b0;
        srcB_reg_div<=32'b0;
        div_busy<=1'b0;
        div_result_sign<=1'b0;
        div_counter<=5'd16;
        logictesterif1<=1'b0;
        logictesterif2<=1'b0;
    end
    else begin
        case(div_state)
            DIV_IDLE: begin
                if(mul_div_op&&mul_div_func[2]) begin
                    //#NORMALIZE by shift both divisor and divident by the number of leading zeros
                    if(abs_srcB[31:0]==32'b0) begin
                        div_quotient<=32'hFFFFFFFF;
                        div_remainder<=abs_srcA;
                        div_busy<=1'b1;
                        div_state<=DIV_FINISH;
                    end
                    else if(!mul_div_func[0]&&abs_srcA==32'h80000000&&abs_srcB==32'hFFFFFFFF) begin
                        div_quotient<=abs_srcA;
                        div_remainder<=0;
                        div_busy<=1'b1;
                        div_state<=DIV_FINISH;
                    end

                    else begin    
                        srcB_reg_div<=abs_srcB<<(srcB_lzc);
                        // srcA_reg_div<=srcA<<(srcB_lzc);
                        div_partial_remainder[64:0]<=abs_srcA<<(srcB_lzc);
                        div_quotient<=32'b0;
                        // div_result<=32'b0;
                        div_result_sign<=(!mul_div_func[0])&&(srcA[31]^srcB[31]);
                        dividend_sign<=srcA[31];
                        div_remainder<=32'b0;
                        div_busy<=1'b1;
                        div_counter<=5'd16;

                        div_state<=DIV_COMPUTE;
                    end
                end
                else begin
                    div_result_sign<=1'b0;
                    dividend_sign<=1'b0;
                    div_busy<=1'b0;
                    logictesterif1<=1'b0;
                    logictesterif2<=1'b0;
                end
            end
            DIV_COMPUTE: begin
                if(div_counter>0) begin
                    div_partial_remainder <= {
                          div_partial_remainder_shift[64:32] - q_digit_mul_div,div_partial_remainder_shift[31:0]};
                    case(quotient_digit)
                            3'b000: begin
                                div_quotient<=(div_quotient<<2)|quotient_digit[1:0];
                                // div_quotient_minus<=(div_quotient_minus<<2)|2'b11;
                            end
                            3'b001: begin
                                div_quotient<=(div_quotient<<2)|quotient_digit[1:0];
                                // div_quotient_minus<=(div_quotient<<2)|quotient_digit[1:0];
                            end
                            3'b010: begin
                                div_quotient<=(div_quotient<<2)|quotient_digit[1:0];
                                // div_quotient_minus<=(div_quotient<<2)|quotient_digit[1:0];
                            end
                            3'b111: begin
                                div_quotient<=(div_quotient<<2)-2'b01;
                                // div_quotient_minus<=(div_quotient_minus<<2)|2'b01;
                            end
                            3'b110: begin
                                div_quotient<=(div_quotient<<2)-2'b10;
                                // div_quotient_minus<=(div_quotient_minus<<2)|2'b10;
                            end
                    endcase
                    div_counter<=div_counter-1'b1;
                end
                else begin
                    div_state<=DIV_FINISH;
                    if(div_partial_remainder[64]==1'b1) begin
                        div_remainder[31:0]<=(div_partial_remainder[64:32]+srcB_reg_div)>>srcB_lzc;
                        div_quotient<=div_quotient-1;
                        logictesterif1<=1'b1;
                    end
                    else begin
                        div_remainder[31:0]<=(div_partial_remainder[64:32])>>srcB_lzc;
                        logictesterif2<=1'b1;
                    end
                end
                // div_state<=DIV_FINISH;
            end
            // DIV_CORRECT: begin
                
            //     // div_result<=div_quotient;
            //     // div_busy<=1'b0;
            //     div_state<=DIV_FINISH;
            // end
            DIV_FINISH: begin
                
                div_state<=DIV_IDLE;
            end
            default: div_state<=DIV_IDLE;
        endcase
    end
end 
// assign div_remainder=div_partial_remainder[64:32];//>>srcB_lzc;
// assign div_result=mul_div_func[1]?div_remainder:div_quotient;

always_comb begin
    case(mul_div_func[1:0])
        2'b00: div_result=div_result_sign?-div_quotient:div_quotient;
        2'b01: div_result=div_quotient;
        2'b10: div_result=dividend_sign?-div_remainder:div_remainder;
        2'b11: div_result=div_remainder;
        default: div_result=32'b0;
    endcase
end
//#TODO REPAIR LUT OVERLAPS CAUSING INCORRECT RESULTS

always_comb begin
    case(quotient_digit)
        3'b000: q_digit_mul_div=0;
        3'b001: q_digit_mul_div=srcB_reg_div;
        3'b010: q_digit_mul_div=srcB_reg_div<<1;
        3'b111: q_digit_mul_div=(~srcB_reg_div+1'b1);
        3'b110: q_digit_mul_div=(~srcB_reg_div+1'b1)<<1;
        default: q_digit_mul_div=0;
    endcase
end

//////////////////////////////
   always_comb begin
        casez(aluOP) /* synthesis parallel_case */
            4'b000?: aluRESULT=add_sub_op;
            4'b0010: aluRESULT=shiftL;
            4'b0011: aluRESULT={31'b0,LessThanSigned};
            4'b0100: aluRESULT={31'b0,LessThan};
            4'b0101: aluRESULT=xor_op;
            4'b0110: aluRESULT=shiftR;
            4'b0111: aluRESULT=shiftRA;
            4'b1000: aluRESULT=or_op;
            4'b1001: aluRESULT=and_op;
            4'b1010: aluRESULT=srcB;//LUI
            4'b1011: aluRESULT=mult_result;
            4'b1100: aluRESULT=div_result;
            default: aluRESULT=32'b0;
   endcase
   end
    //assign zero=aluRESULT==32'b0;
    //assign overflow=aluRESULT[31]^aluRESULT[30];
//we or the bits of the result and invert
//     always_comb begin
//         case(aluOP) /* synthesis parallel_case */
//             4'b0000: aluRESULT=srcA+srcB;
//             4'b0001: aluRESULT=srcA-srcB;
//             4'b0010: aluRESULT=srcA<<srcB[4:0];
//             4'b0011: aluRESULT={31'b0,$signed(srcA)<$signed(srcB)};
//             4'b0100: aluRESULT={31'b0,srcA<srcB};
//             4'b0101: aluRESULT=srcA^srcB;
//             4'b0110: aluRESULT=srcA>>srcB[4:0];
//             4'b0111: aluRESULT=$signed(srcA)>>>srcB[4:0];
//             4'b1000: aluRESULT=srcA|srcB;
//             4'b1001: aluRESULT=srcA&srcB;
// //            4'b1010: aluRESULT=srcA*srcB;
// //            4'b1011: aluRESULT=srcA/srcB;
//             4'b1010: aluRESULT=srcB;//LUI
//             default: aluRESULT=32'b0;
//         endcase
//     end
endmodule

/*
`timescale 1ns/1ps
module alu(input logic [31:0] srcA, srcB,
           input logic [3:0] aluOP,
           output logic [31:0] aluRESULT); 

    // Use parameters to prevent bitwidth mismatch
    parameter ADD_OP = 4'b0000,
              SUB_OP = 4'b0001,
              SLL_OP = 4'b0010,
              SLT_OP = 4'b0011,
              SLTU_OP = 4'b0100,
              XOR_OP = 4'b0101,
              SRL_OP = 4'b0110,
              SRA_OP = 4'b0111,
              OR_OP = 4'b1000,
              AND_OP = 4'b1001,
              LUI_OP = 4'b1010;

    // Arithmetic operations
    wire [31:0] add_result = srcA + srcB;
    wire [31:0] sub_result = srcA - srcB;
    
    // Logical operations
    wire [31:0] and_result = srcA & srcB;
    wire [31:0] or_result = srcA | srcB;
    wire [31:0] xor_result = srcA ^ srcB;
    
    // Shifts
    wire [4:0] shamt = srcB[4:0];
    wire [31:0] sll_result = srcA << shamt;
    wire [31:0] srl_result = srcA >> shamt;
    wire [31:0] sra_result = $signed(srcA) >>> shamt;
    
    // Comparisons
    wire srcA_sign = srcA[31];
    wire srcB_sign = srcB[31];
    wire signed_lt = (srcA_sign != srcB_sign) ? srcA_sign : sub_result[31];
    wire unsigned_lt = sub_result[31]; // Carry out of subtraction
    
    wire [31:0] slt_result = {31'b0, signed_lt};
    wire [31:0] sltu_result = {31'b0, unsigned_lt};
    
    // Operation decoder
    reg [10:0] op_select;
    always_comb begin
        op_select = 11'b0;
        case(aluOP)
            ADD_OP:  op_select[0] = 1'b1;
            SUB_OP:  op_select[1] = 1'b1;
            SLL_OP:  op_select[2] = 1'b1;
            SLT_OP:  op_select[3] = 1'b1;
            SLTU_OP: op_select[4] = 1'b1;
            XOR_OP:  op_select[5] = 1'b1;
            SRL_OP:  op_select[6] = 1'b1;
            SRA_OP:  op_select[7] = 1'b1;
            OR_OP:   op_select[8] = 1'b1;
            AND_OP:  op_select[9] = 1'b1;
            LUI_OP:  op_select[10] = 1'b1;
            default: op_select[0] = 1'b1;
        endcase
    end
    
    // Parallel multiplexer using bit masking (true one-hot mux)
    assign aluRESULT = ({32{op_select[0]}} & add_result) |
                       ({32{op_select[1]}} & sub_result) |
                       ({32{op_select[2]}} & sll_result) |
                       ({32{op_select[3]}} & slt_result) |
                       ({32{op_select[4]}} & sltu_result) |
                       ({32{op_select[5]}} & xor_result) |
                       ({32{op_select[6]}} & srl_result) |
                       ({32{op_select[7]}} & sra_result) |
                       ({32{op_select[8]}} & or_result) |
                       ({32{op_select[9]}} & and_result) |
                       ({32{op_select[10]}} & srcB);
endmodule
*/