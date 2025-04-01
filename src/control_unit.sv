`timescale 1ns/1ps
module ControlUnit( input  logic [31:0] instruction,
                    output logic        branch,
                    output logic        jump,
                    output logic        is_jalr,
                    output logic [3:0]  aluOP,
                    output logic        aluSRCA,
                    output logic        aluSRCB,
                    output logic        reg_write,
                    output logic        mul_div_op,
                    output logic [1:0]  WriteBackSRC,
                    output logic        mem_write,
                    output logic        mem_read,
                    output logic        ill_instr_exception,
                    output logic        ecall_exception,
                    output logic        ebreak_exception,
                    output logic        csr_op,
                    output logic        csr_immd,
                    output logic [2:0]  csr_op_type,
                    output logic [2:0]  immd_type);

//Zicsr,Zicntr and Zifencei will be forced ON//
///////////////////////////////////////////////
//output logic mul_div_op   //M extension    //
//output logic float_op     //F/D extension  //
//output logic atomic_op    //A extension    //
//output logic csr_op       //Zicsr extension//
//output logic [2:0] csr_type                //
///////////////////////////////////////////////
//input logic stall, flush //pipeline signals//
//////////////////////////////////////////////
////BASE INSTRUCTION SET///////////////////////
//OPCODE:0110011 OP -> R TYPE                //
//OPCODE:0010011|1100111 OP-IMM|JALR ->I TYPE//
//OPCODE:0100011 STORES -> S-TYPE            //
//OPCODE:0?10111 LUI/AUIPC -> U-TYPE         //
//OPCODE:1101111 JAL -> J-TYPE               //
//OPCODE:1100011 BRANCH -> B-TYPE            //
//OPCODE:1110011 SYSTEM                      //
//OPCODE:0001111 MISC-MEM                    //
///////////////////////////////////////////////
////Zifencei///////////////////////////////////
//OPCODE:0001111 FENCE.I -> I TYPE           //
///////////////////////////////////////////////
////Zicsr//////////////////////////////////////
//OPCODE:1110011 SYSTEM                      //
///////////////////////////////////////////////
////A EXTENSION////////////////////////////////
//OPCODE:0101111 AMO -> R-TYPE               //
///////////////////////////////////////////////
////M EXTENSION////////////////////////////////
//OPCODE:0110011 OP -> R TYPE                //
///////////////////////////////////////////////
////DECLARATIONS///////////////////////////////
    localparam M_EXTENSION=1;
    localparam A_EXTENSION=0;
    localparam C_EXTENSION=0;
    localparam F_EXTENSION=0;
    localparam CSR_ENV=2'b00;
    localparam CSR_RW=2'b01;
    localparam CSR_RS=2'b10;
    localparam CSR_RC=2'b11;
    localparam ECALL=12'h000;
    localparam EBREAK=12'h001;
    localparam MRET=12'h302;
    // localparam SRET=12'h102;
    // localparam MNRET=12'h702;
    // localparam WFI=12'h105;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] funct12;
//    logic mul_div_op;
//    logic csr_type
///ASSIGNMENTS/////
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    assign funct12= instruction[31:20];
/////COMBINATIONAL DECODING/////
    always_comb begin /* synthesis parallel_case */
        //if opcode[1:0]!=2'b11 then its illegal? also all zeros
        ill_instr_exception=(opcode[1:0]!=2'b11)&&~C_EXTENSION;
        branch      = 1'b0;
        jump        = 1'b0;
        is_jalr     = 1'b0;
        aluOP       = 4'b0;
        aluSRCA     = 1'b1; //assert reading from readport1
        aluSRCB     = 1'b0;//readport2
        reg_write   = 1'b0;
        WriteBackSRC= 2'b00;
        mem_write   = 1'b0;
        mem_read    = 1'b0;
        mul_div_op  = 1'b0;
        immd_type   = 3'b0;
        csr_op      = 1'b0;
        csr_op_type = 3'b0;
        csr_immd    = 1'b0;
        ecall_exception =1'b0;
        ebreak_exception=1'b0;
        casez(opcode[6:2])
//            5'b01011: begin //AMO
//                
//            end

            /////INTEGER BASE ISA/////
            5'b00000: begin //LOAD I-TYPE
                WriteBackSRC=2'b01;
                aluSRCB=1'b1;
                immd_type=3'b000;
                reg_write=1'b1;
                mem_read=1'b1;
                aluOP=4'b0000;
            end
            
            5'b01000: begin //STORE S-TYPE
                mem_write=1'b1;
                aluSRCB=1'b1;
                immd_type=3'b001;
                aluOP=4'b0000;
            end
               
            5'b00101: begin //AUIPC U-TYPE
                immd_type=3'b011;
                aluSRCA=1'b0;
                aluSRCB=1'b1;
                aluOP=4'b0000;
                reg_write=1'b1;
                WriteBackSRC=2'b00;
            end

             5'b01101: begin //LUI U-TYPE
                immd_type=3'b011;
                aluSRCB=1'b1;
                aluOP=4'b1010;
                reg_write=1'b1;
            end
            
            5'b11011: begin //JAL J-TYPE
                jump=1'b1;
                immd_type=3'b100;
                WriteBackSRC=2'b10;
                reg_write=1'b1;
                
            end

            5'b11001: begin //JALR I-TYPE
                jump=1'b1;
                immd_type=3'b000;
                WriteBackSRC=2'b10;
                reg_write=1'b1;
                is_jalr  = 1'b1;
            end

            5'b11000: begin //BRANCHES B-TYPE
                branch=1'b1;
                immd_type=3'b010;
                case(funct3)
                    3'b000: aluOP=4'b0001;
                    3'b001: aluOP=4'b0001;
                    3'b100: aluOP=4'b0011;
                    3'b101: aluOP=4'b0011;
                    3'b110: aluOP=4'b0100;
                    3'b111: aluOP=4'b0100;
                endcase
            end
//            5'b00011: begin //MISC-MEM: FENCE.I, FENCE, FENCE.ISO, PAUSE
//        
//            end

            5'b11100: begin //SYSTEM: ECALL, EBREAK, ZICSR stuff
                csr_immd=funct3[2];
                immd_type=3'b101;
                WriteBackSRC=2'b11;
                //csrSRC=funct3[2];
                case(funct3[1:0])
                    CSR_ENV: begin
                        case(funct12)
                            ECALL: begin
                                //call ecall handler
                                csr_op_type=3'b000;
                                ecall_exception=1'b1;
                            end
                            EBREAK: begin
                                //call ebreak handler
                                csr_op_type=3'b000;
                                ebreak_exception=1'b1;
                            end
                            MRET: begin
                                csr_op_type=3'b110;
                                csr_op=1'b1;
                                // is_ret=1'b1;//return from trap
                                //call mret handler
                            end
                            // SRET: begin
                            //     csr_op_type=3'b111;
                            //     // is_ret=1'b1;//return from trap
                            //     //call sret handler
                            // end
                            default: begin
                                //call illegal instruction handler
                                csr_op=1'b0;
                                ill_instr_exception=1'b1;

                            end
                        endcase
                    end
                    CSR_RW: begin
                        //csr atomic RW
                        csr_op_type=3'b001;
                        reg_write=1'b1;
                        csr_op=1'b1;
                    end
                    CSR_RS: begin
                        //csr atomic read and set bits
                        csr_op_type=3'b010;
                        reg_write=1'b1;
                        csr_op=1'b1;
                    end
                    CSR_RC: begin
                        //cst atomic read and clear bits
                        csr_op_type=3'b011;
                        reg_write=1'b1;
                        csr_op=1'b1;
                    end
                    default: begin
                        //call illegal instruction handler
                        csr_op=1'b0;
                        ill_instr_exception=1'b1;

                    end
                endcase
            end

            5'b0?100: begin //OP-IMM, OP groups and M EXTENSION
                aluSRCB=~opcode[5];//invert bit for immediate src. 1=immd, 0=reg
                mul_div_op=(M_EXTENSION&&funct7[0]&&opcode[5]);//Handles MUL/DIV M EXENSION
                reg_write=1'b1;
                WriteBackSRC=2'b00;
                // #TODO REDO ALU OP DECODING maybe
                if(mul_div_op) begin
                    aluOP=funct3[2]?4'b1100:4'b1011;//funct3[2]==1->DIV else MUL
                end
                else begin
                    case(funct3)
                        3'b000: aluOP=(funct7[5]&&opcode[5])?4'b0001:4'b0000; //funct7[5]==0->ADD else SUB
                        3'b001: aluOP=4'b0010;//SLL[i]
                        3'b010: aluOP=4'b0011;//SLT[i]
                        3'b011: aluOP=4'b0100;//SLT[i]U
                        3'b100: aluOP=4'b0101;//XOR[i]
                        3'b101: aluOP=(funct7[5])?4'b0111:4'b0110;//funct7[5]==0->SRL else SRA
                        3'b110: aluOP=4'b1000;//OR[i]
                        3'b111: aluOP=4'b1001;//AND[i]
                    endcase
                end
            end
            
            // default:ill_instr_exception=1'b1;
        
        ////////M EXTENSION////////
        endcase
    end
endmodule