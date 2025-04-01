// 
// 
// 144MHZ core clk// actually 74 after the hazard unit and fwd muxes
// 
// 
`timescale 1ns/1ps
module pipelined_core( input  logic         clk,
             input  logic         reset,
             input  logic [31:0]  instruction,
             input  logic [31:0]  ReadData,
             output logic [31:0]  pc_out,
             output logic [31:0]  DataADDR,WriteData,
//              output logic [31:0]  BranchADDR,
//              output logic [31:0]  targetADDR,
             output logic         missaligned_exception,
             output logic         misaligned_load_exception,
             output logic         misaligned_store_exception,
             output logic [3:0]   mem_write_req,
             output logic         mem_read_req,
             output logic         ill_instr_exception
//              output logic         branchTaken
             );
/////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////
///////IF STAGE SIGNALS///////////////////////
logic [1:0] pc_src;
logic  [31:0] pc_next;
//////ID STAGE SIGNALS///////////////////////
logic branch,jump,aluSRC,is_jalr;
logic reg_write,mul_div_op;
logic mem_read,mem_write;
logic [3:0] aluOP;
logic [2:0] immd_type;
logic [4:0]  readPort1SEL,readPort2SEL,writePortSEL;
logic [1:0] WriteBackSRC;
logic  [31:0] immd_ext,writeBack,readPort1,readPort2,aluPortB,aluPortA,aluRESULT,addrADDERPortA;
logic [31:0] ID_instruction,pc_out_ID,pc_next_ID;
logic [2:0] funct3;
////////EX STAGE SIGNALS///////////////////////
logic [31:0] pc_out_EX,pc_next_EX,readPort2_EX,immd_ext_EX,BranchADDR;
logic [2:0] funct3_EX;
logic [3:0] aluOP_EX;
logic [1:0] WriteBackSRC_EX;
logic [4:0] writePortSEL_EX,readPort1SEL_EX,readPort2SEL_EX;
logic branch_EX,jump_EX,mem_read_EX,mem_write_EX,reg_write_EX,aluSRCB_EX,is_jalr_EX;
logic [31:0] aluPortB_mux_out_EX,aluPortA_mux_out_EX,addrADDERPortA_EX;

logic branchTaken;
////////MEM STAGE SIGNALS///////////////////////
logic [31:0] pc_next_MEM,readPort2_MEM,aluRESULT_MEM;
logic [2:0] funct3_MEM;
logic mem_write_MEM;
logic mem_read_MEM,reg_write_MEM;
logic [4:0] writePortSEL_MEM;
logic [1:0] WriteBackSRC_MEM;
logic [31:0] ReadDataLSU_out;
////////WB STAGE SIGNALS///////////////////////
logic [4:0] writePortSEL_WB;
logic [31:0] pc_next_WB,aluRESULT_WB,ReadDataLSU_out_WB;
logic [1:0] WriteBackSRC_WB;
logic reg_write_WB;
////////HAZARD SIGNALS////////////////////////////
logic stall,flushID,flushEX;
logic [1:0] forwardA,forwardB;
logic [31:0] addr_adder_inputA_mux_out,aluPortA_mux_out,aluPortB_mux_out;
///////CSR UNIT SIGNALS///////////////////////////
logic [31:0] csr_out,csr_out_MEM,csr_out_WB,csr_in,trap_vector;
logic [11:0] csr_addr,csr_addr_EX;
logic [2:0] csr_op_type,csr_op_type_EX;
logic csr_op,csr_op_EX,ebreak_exception,ecall_exception,trap_REQ;
logic [31:0] csr_mux;
logic csr_immd, csr_immd_EX;

logic pc_on_exception;
assign csr_mux=(csr_immd_EX)?immd_ext_EX:aluPortA_mux_out_EX; //#TODO MOVE THIS INTO ID (MUX immd Ext and readPort1)
assign csr_addr=ID_instruction[31:20];
assign csr_in=(forwardA==2'b10)?DataADDR:((forwardA==2'b01)?writeBack:csr_mux);
// assign pc_on_exception=(ebreak_exception|ecall_exception)?pc_out_ID:pc_out_MEM;
/////////////////////////////////////////////////////////////////////////////
///////////////////////////Instruction Fetch Stage///////////////////////////    
    assign pc_src[0] = branchTaken&~trap_REQ;
    assign pc_src[1] = trap_REQ;
    ProgramCounter PC(.clk(clk),
                      .reset(reset),
                      .pc_src(pc_src),
                      .en_n(stall),
                      .trap_vector(trap_vector),
                      .BranchADDR(BranchADDR),
                      .pc(pc_out),
                      .pc_next(pc_next)
                     );
    ////IF/ID pipeline register
    pipeline_reg #(96,32'h00000013) IF_ID_reg(.clk(clk),
                                 .reset(reset|flushID),
                                 .en_n(stall),
                                 .in({pc_out,pc_next,instruction}),
                                 .out({pc_out_ID,pc_next_ID,ID_instruction}));
// assign pc_out_ID =IF_ID_out[95:64];
// assign pc_next_ID =  IF_ID_out[63:32];
// assign ID_instruction = IF_ID_out[31:0];
assign funct3 = ID_instruction[14:12];
assign readPort1SEL=ID_instruction[19:15];
assign readPort2SEL=ID_instruction[24:20];
assign writePortSEL=ID_instruction[11:7];

///////////////////////////Instruction Decode Stage///////////////////////////
    ControlUnit CU(.instruction(ID_instruction),
                   .branch(branch),
                   .jump(jump),
                   .is_jalr(is_jalr),
                   .aluOP(aluOP),
                   .aluSRCA(aluSRCA),
                   .aluSRCB(aluSRCB),
                   .reg_write(reg_write),
                   .mul_div_op(mul_div_op),
                   .WriteBackSRC(WriteBackSRC),
                   .mem_write(mem_write),
                   .mem_read(mem_read),
                   .ill_instr_exception(ill_instr_exception),
                   .ecall_exception(ecall_exception),
                   .ebreak_exception(ebreak_exception),
                   .csr_op(csr_op),
                   .csr_immd(csr_immd),
                   .csr_op_type(csr_op_type),
                   .immd_type(immd_type));
    regfile REGFILE(.clk(clk),
                    .WE(reg_write_WB),
                    .readPort1SEL(readPort1SEL),
                    .readPort2SEL(readPort2SEL),
                    .writePortSEL(writePortSEL_WB),
                    .writePort(writeBack),
                    .readPort1(readPort1),
                    .readPort2(readPort2));
    
    ImmediateGenerator IMMD_GEN(.instruction(ID_instruction[31:7]),
                                .ImmSrc(immd_type),
                                .Immd(immd_ext));


                             
    // mux2to1 #(32) alu_portB_mux(.SEL(aluSRCB),
    //                             .in_a(readPort2),
    //                             .in_b(immd_ext),
    //                             .out(aluPortB_mux_out));


    mux2to1 #(32) alu_portA_mux(.SEL(aluSRCA),
                                .in_a(pc_out_ID),
                                .in_b(readPort1),
                                .out(aluPortA_mux_out));

    mux2to1 #(32) addr_adder_inputA_mux(.SEL(is_jalr),
                                        .in_a(pc_out_ID),
                                        .in_b(readPort1),
                                        .out(addr_adder_inputA_mux_out));                                

    pipeline_reg #(244) ID_EX_reg(.clk(clk),
                                 .reset(reset|flushEX),
                                 .en_n(ALUbusy),
                                 .in({pc_out_ID,pc_next_ID,readPort2,immd_ext,
                                      aluPortA_mux_out,addr_adder_inputA_mux_out,WriteBackSRC,funct3,
                                      branch,jump,mem_read,mem_write,reg_write,writePortSEL,readPort1SEL,readPort2SEL,aluOP,aluSRCB,is_jalr,csr_immd,csr_op,csr_op_type,csr_addr, ill_instr_exception,ecall_exception,ebreak_exception,mul_div_op}),
                                 .out({pc_out_EX,pc_next_EX,readPort2_EX,immd_ext_EX,
        /*aluPortB_mux_out_EX,*/aluPortA_mux_out_EX,addrADDERPortA_EX,WriteBackSRC_EX,funct3_EX,branch_EX,jump_EX,mem_read_EX,mem_write_EX,reg_write_EX,
        writePortSEL_EX,readPort1SEL_EX,readPort2SEL_EX,aluOP_EX,aluSRCB_EX,is_jalr_EX,csr_immd_EX,csr_op_EX,csr_op_type_EX,csr_addr_EX,ill_instr_exception_EX,ecall_exception_EX,ebreak_exception_EX,mul_div_op_EX}));

///////////////////////////Execution Stage///////////////////////////////////
// assign {} = ID_EX_out;

assign aluPortA= (forwardA==2'b10&&!csr_op_MEM)?DataADDR:(forwardA==2'b10&&csr_op_MEM)?csr_out_MEM:((forwardA==2'b01)?writeBack:aluPortA_mux_out_EX);
/* ALU PORT A MUX ALTERNATIVE
wire forward_from_mem_A = forwardA[1];  // Extract individual select bits
wire forward_from_wb_A = forwardA[0] & ~forwardA[1];  // Priority encoded
wire use_normal_A = ~(forward_from_mem_A | forward_from_wb_A);
assign aluPortA = ({32{forward_from_mem_A}} & aluRESULT_MEM) | 
                 ({32{forward_from_wb_A}} & writeBack) |
                 ({32{use_normal_A}} & aluPortA_mux_out_EX);
*/
assign aluPortB_mux_out_EX= (forwardB==2'b10)?DataADDR:((forwardB==2'b01)?writeBack:readPort2_EX);
//move MUX for RS2xIMMD back to ID, through the pipeline expose both. Only one mux remaining.
//maybe test this theory #TODO
mux2to1 #(32) alu_portB_mux(.SEL(aluSRCB_EX),
                                .in_a(aluPortB_mux_out_EX),
                                .in_b(immd_ext_EX),
                                .out(aluPortB));
// assign aluPortB=(aluSRCB_EX==1'b1)?immd_ext_EX:aluPortB_mux_out_EX;
/* ALU PORT B MUX ALTERNATIVE
wire forward_from_mem_B = forwardB[1];
wire forward_from_wb_B = forwardB[0] & ~forwardB[1];
wire use_normal_B = ~(forward_from_mem_B | forward_from_wb_B);

assign aluPortB_mux_out_EX = ({32{forward_from_mem_B}} & aluRESULT_MEM) | 
                            ({32{forward_from_wb_B}} & writeBack) |
                            ({32{use_normal_B}} & readPort2_EX);

wire use_reg_val = ~aluSRCB_EX;
wire use_imm = aluSRCB_EX;

assign aluPortB = ({32{forward_from_mem_B & use_reg_val}} & aluRESULT_MEM) | 
                 ({32{forward_from_wb_B & use_reg_val}} & writeBack) |
                 ({32{use_normal_B & use_reg_val}} & readPort2_EX) |
                 ({32{use_imm}} & immd_ext_EX);

*/
assign addrADDERPortA= is_jalr_EX?((forwardA==2'b10)?DataADDR:((forwardA==2'b01)?writeBack:addrADDERPortA_EX)):addrADDERPortA_EX;     
    BranchUnit BRANCH_UNIT(.srcA(aluPortA),
                            .srcB(aluPortB),
                            .BranchAddr(BranchADDR[1:0]),
                           .branchType(funct3_EX),
                        //    .zero(zero),
                           .branch(branch_EX),
                           .jump(jump_EX),
                           .branchTaken(branchTaken),
                           .missaligned_exception(missaligned_exception)
                        //    .targetADDR(targetADDR)
                        );
    AdressAdder ADDRESS_ADDER(.srcA(addrADDERPortA),.srcB(immd_ext_EX),.BranchAddr(BranchADDR));
    alu ALU(.clk(clk),
            .reset(reset),
            .srcA(aluPortA),
            .srcB(aluPortB),
            .aluOP(aluOP_EX),
            .mul_div_func(funct3_EX),
            .mul_div_op(mul_div_op_EX),
            .ALUbusy(ALUbusy),
//            .zero(zero),
            .aluRESULT(aluRESULT));

    pipeline_reg #(142) EX_MEM_reg(.clk(clk),
                                 .reset(reset|flushMEM),
                                 .en_n(ALUbusy),
                                 .in({pc_next_EX,aluPortB_mux_out_EX/*readPort2 forwarded but not aff by immd*/,aluRESULT,funct3_EX,WriteBackSRC_EX,mem_read_EX,mem_write_EX,reg_write_EX,writePortSEL_EX,csr_out,csr_op_EX}),
                                 .out({pc_next_MEM,readPort2_MEM,DataADDR,funct3_MEM,WriteBackSRC_MEM,mem_read_MEM,mem_write_MEM,reg_write_MEM,writePortSEL_MEM,csr_out_MEM,csr_op_MEM}));
///////////////////////////Memory Stage//////////////////////////////////////
// assign DataADDR=aluRESULT_MEM;
// assign {/*,branchTaken_MEM*/} = EX_MEM_out;
    LoadStoreUnit LSU_MEM(.LoadData(ReadData),
                        .StoreData(readPort2_MEM),
                        .Address(DataADDR[1:0]),
                        .funct3(funct3_MEM),
                        .mem_read(mem_read_MEM),
                        .mem_write(mem_write_MEM),
                        .LoadDataOut(ReadDataLSU_out),
                        .StoreDataOut(WriteData),
                        .misaligned_load_exception(misaligned_load_exception),
                        .misaligned_store_exception(misaligned_store_exception),
                        .mem_write_req(mem_write_req),
                        .mem_read_req(mem_read_req));


//////////////////////// ////
// DataADDR=aluRESULT_MEM;///
// //////////////////////////
    pipeline_reg #(136) MEM_WB_reg(.clk(clk),
                                 .reset(reset),
                                 .en_n(1'b0),
                                 .in({pc_next_MEM,DataADDR,ReadDataLSU_out,WriteBackSRC_MEM,reg_write_MEM,writePortSEL_MEM,csr_out_MEM}),
                                 .out({pc_next_WB,aluRESULT_WB,ReadDataLSU_out_WB,WriteBackSRC_WB,reg_write_WB,writePortSEL_WB,csr_out_WB}));


///////////////////////////WRITEBACK MUX BEFORE WRITEBACK STAGE//////////////////////
// logic [31:0] writeBack_MEM;
//     mux3to1 #(32) regfile_write_src(.SEL(WriteBackSRC_MEM),
//                                    .in_a(DataADDR),
//                                    .in_b(ReadDataLSU_out),
//                                    .in_c(pc_next_MEM),
//                                    .out(writeBack_MEM));
// always_ff @(posedge clk) begin
//     WriteBackSRC_WB<=WriteBackSRC_MEM;
//     reg_write_WB<=reg_write_MEM;
//     writePortSEL_WB<=writePortSEL_MEM;
//     writeBack<=writeBack_MEM;
// end
///////////////////////////Write Back Stage///////////////////////////////////////

    
    mux3to1 #(32) regfile_write_src(.SEL(WriteBackSRC_WB),
                                   .in_a(aluRESULT_WB),
                                   .in_b(ReadDataLSU_out_WB),
                                   .in_c(pc_next_WB),
                                   .in_d(csr_out_WB),
                                   .out(writeBack));

   //make load/store instructions. they should be aligned on 4,2,no byte respcectively for full word, half word and byte loads/stores
    
    HazardUnit HAZARD_UNIT(
    .rs1_ID(readPort1SEL),
    .rs2_ID(readPort2SEL),
    .rs1_EX(readPort1SEL_EX),
    .rs2_EX(readPort2SEL_EX),
    .wd_EX(writePortSEL_EX),
    .wd_MEM(writePortSEL_MEM),
    .wd_WB(writePortSEL_WB),
    .mem_read_EX(mem_read_EX),
    .reg_write_MEM(reg_write_MEM),
    .reg_write_WB(reg_write_WB),
    .trapped(trap_REQ),
    .branch_taken(branchTaken),
    .ALUbusy(ALUbusy),
    .stall(stall),
    .flushID(flushID),
    .flushEX(flushEX),
    .flushMEM(flushMEM),
    .forwardA(forwardA),
    .forwardB(forwardB)
    );
    CSRUnit CSR_UNIT(.clk(clk),
                     .reset(reset),
                     .csr_op(csr_op_EX),
                     .csr_type(csr_op_type_EX),
                     .csr_addr(csr_addr_EX),
                     .csr_in(csr_in),
                     .pc_on_exception(pc_out_EX),
                     .ill_instr_exception(ill_instr_exception_EX),
                     .ecall_exception(ecall_exception_EX),
                     .ebreak_exception(ebreak_exception_EX),
                     .misaligned_store_exception(misaligned_store_exception),
                     .misaligned_load_exception(misaligned_load_exception),
                     .csr_out(csr_out),
                     .trap_vector(trap_vector),
                     .trap_REQ(trap_REQ));
        
endmodule