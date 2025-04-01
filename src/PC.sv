`timescale 1ns/1ps
module ProgramCounter(input logic clk,
                      input logic reset,
                      input logic [1:0] pc_src,
                      input logic en_n,
                      input logic [31:0] trap_vector,   
                      input logic [31:0] BranchADDR,
                      output logic [31:0] pc,
                      output logic [31:0] pc_next)/*synthesis syn_dspstyle = "dsp" */;
    localparam is_compressed=0;
    // assign pc_inc=is_compressed?32'd2:32'd4;
    assign pc_next=pc+4;///handle compression
    ///for example use a signal called pc_inc_mode to switch between pc+2 and pc+4
    always_ff @(posedge clk) begin
        if(reset) pc<=32'h00000000;//RESET VECTOR
        else if(~en_n) 
            casez(pc_src)
                2'b00: pc<=pc_next;
                2'b01: pc<=BranchADDR;
                2'b10: pc<=trap_vector;
            endcase
    end
endmodule