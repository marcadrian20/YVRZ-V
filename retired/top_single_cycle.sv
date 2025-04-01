`timescale 1ns/1ps
module top_single_cycle(input logic         clk,
           input logic         reset,
           output logic [31:0] WriteData,
           output logic [31:0] instruction,
           output logic [31:0] pc,
           output logic [31:0] DataADDR,ReadData,
           output logic [3:0]  mem_write_req,
           output logic         mem_read_req,
           output logic        missaligned_exception,
           output logic        misaligned_load_exception,
           output logic        misaligned_store_exception,
           output logic        ill_instr_exception
);
    


    single_cycle_core SINGLE_CYCLE_CORE(.clk(clk),
             .reset(reset),
             .instruction(instruction),
             .ReadData(ReadData),
             .pc_out(pc),
             .WriteData(WriteData),
             .DataADDR(DataADDR),
             .missaligned_exception(missaligned_exception),
             .misaligned_load_exception(misaligned_load_exception),
             .misaligned_store_exception(misaligned_store_exception),
             .mem_write_req(mem_write_req),
             .mem_read_req(mem_read_req),
             .ill_instr_exception(ill_instr_exception));

    iram IRAM(.addr(pc),
              .rd(instruction)
             );
    ram RAM(.clk(clk),
            .we(mem_write_req),
            .addr(DataADDR),
            .DATA_IN(WriteData),
            .DATA_OUT(ReadData));
endmodule