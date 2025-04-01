`timescale 1ns/1ps
module single_cycle_core( input  logic         clk,
             input  logic         reset,
             input  logic [31:0]  instruction,
             input  logic [31:0]  ReadData,
             output logic [31:0]  pc_out,
             output logic [31:0]  DataADDR,WriteData,
             output logic         missaligned_exception,
             output logic         misaligned_load_exception,
             output logic         misaligned_store_exception,
             output logic [3:0]   mem_write_req,
             output logic         mem_read_req,
             output logic         ill_instr_exception
             );

logic branch,jump,aluSRC,AddrAddSRC;
logic reg_write;
logic mem_read,mem_write;
logic [3:0] aluOP;
logic [2:0] immd_type;
logic [4:0]  readPort1SEL,readPort2SEL,writePortSEL;
logic [1:0] WriteBackSRC;
logic  [31:0] immd_ext,writeBack,readPort1,readPort2,aluPortB,aluPortA,aluRESULT,pc_next,BranchADDR,targetADDR,addrADDERPortA;
logic [31:0] ReadDataLSU_out;
logic zero;
    assign readPort1SEL=instruction[19:15];
    assign readPort2SEL=instruction[24:20];
    assign writePortSEL=instruction[11:7];
    assign DataADDR=aluRESULT;
//     assign WriteData=readPort2;
    assign pc_src = ~(jump | branchTaken);
///////////////////////////Instruction Fetch Stage///////////////////////////    
    ProgramCounter PC(.clk(clk),
                      .reset(reset),
                      .en_n(1'b0),
                      .pc_src(pc_src),
                      .BranchADDR(targetADDR),
                      .pc(pc_out),
                      .pc_next(pc_next)
                     );

///////////////////////////Instruction Decode Stage///////////////////////////
    ControlUnit CU(.instruction(instruction),
                   .branch(branch),
                   .jump(jump),
                   .AddrAddSRC(AddrAddSRC),
                   .aluOP(aluOP),
                   .aluSRCA(aluSRCA),
                   .aluSRCB(aluSRCB),
                   .reg_write(reg_write),
                   .WriteBackSRC(WriteBackSRC),
                   .mem_write(mem_write),
                   .mem_read(mem_read),
                   .ill_instr_exception(ill_instr_exception),
                   .immd_type(immd_type));
    regfile REGFILE(.clk(clk),
                    .WE(reg_write),
                    .readPort1SEL(readPort1SEL),
                    .readPort2SEL(readPort2SEL),
                    .writePortSEL(writePortSEL),
                    .writePort(writeBack),
                    .readPort1(readPort1),
                    .readPort2(readPort2));
    
    ImmediateGenerator IMMD_GEN(.instruction(instruction[31:7]),
                                .ImmSrc(immd_type),
                                .Immd(immd_ext));

///////////////////////////Execution Stage///////////////////////////////////
    mux2to1 #(32) alu_portB_mux(.SEL(aluSRCB),
                                .in_a(readPort2),
                                .in_b(immd_ext),
                                .out(aluPortB));
    
    mux2to1 #(32) alu_portA_mux(.SEL(aluSRCA),
                                .in_a(pc_out),
                                .in_b(readPort1),
                                .out(aluPortA));
    
    BranchUnit BRANCH_UNIT(.srcA(aluPortA),
                            .srcB(aluPortB),
                           .BranchAddr(BranchADDR),
                           .branchType(instruction[14:12]),
//                           .zero(zero),
                           .branch(branch),
                           .jump(jump),
                           .branchTaken(branchTaken),
                           .missaligned_exception(missaligned_exception),
                           .targetADDR(targetADDR));
    
    mux2to1 #(32) addr_adder_inputA_mux(.SEL(AddrAddSRC),
                                        .in_a(readPort1),
                                        .in_b(pc_out),
                                        .out(addrADDERPortA));
    
    AdressAdder ADDRESS_ADDER(.srcA(addrADDERPortA),.srcB(immd_ext),.BranchAddr(BranchADDR));
    
    alu ALU(.srcA(aluPortA),
            .srcB(aluPortB),
            .aluOP(aluOP),
            .zero(zero),
            .aluRESULT(aluRESULT));
///////////////////////////Memory Stage//////////////////////////////////////
    LoadStoreUnit LSU(  .LoadData(ReadData),
                        .StoreData(readPort2),
                        .Address(DataADDR[1:0]),
                        .funct3(instruction[14:12]),
                        .mem_read(mem_read),
                        .mem_write(mem_write),
                        .LoadDataOut(ReadDataLSU_out),
                        .StoreDataOut(WriteData),
                        .misaligned_load_exception(misaligned_load_exception),
                        .misaligned_store_exception(misaligned_store_exception),
                        .mem_write_req(mem_write_req),
                        .mem_read_req(mem_read_req));
///////////////////////////Write Back Stage//////////////////////////////////
    mux3to1 #(32) regfile_write_src(.SEL(WriteBackSRC),
                                   .in_a(aluRESULT),
                                   .in_b(ReadDataLSU_out),
                                   .in_c(pc_next),
                                   .out(writeBack));

   //make load/store instructions. they should be aligned on 4,2,no byte respcectively for full word, half word and byte loads/stores

endmodule