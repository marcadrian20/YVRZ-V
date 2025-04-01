module HazardUnit (
                    input logic [4:0] rs1_ID,rs2_ID,
                   input logic [4:0] rs1_EX,rs2_EX,wd_EX,
                   input logic [4:0] wd_MEM,
                   input logic [4:0] wd_WB,
                   input logic mem_read_EX,
                   input logic reg_write_MEM,
                   input logic reg_write_WB,
                   input logic trapped,
                   input logic branch_taken,
                   input logic ALUbusy,
                   output logic stall,
                   output logic flushID,
                   output logic flushEX,
                   output logic flushMEM,
                   output logic [1:0] forwardA,
                   output logic [1:0] forwardB
                   )/*synthesis syn_dspstyle = "dsp" */;

//TODO Implement Hazard Unit
// FIGURE OUT in docs if i need a single flush single stall or multiple flushes and stalls
//look again at the pipeline diagram and hazards
//Use muxes to select between forwarding results
//After the hazard unit, make the branch predictor(possibly 2 bit predictor)
//Solve branching stuff. the signal for the addr adder mux might be unneeded, maybe use the aluSRCA?
logic load_stall;
// logic mem_read_ff;
// logic branch_taken_ff;
// always_ff @(posedge clk) begin
//     branch_taken_ff<=branch_taken;
// end
// always_ff @(posedge clk) begin
//     flushID<=branch_taken;
//     flushEX<=branch_taken|load_stall;
// end

// logic rs1_eq_mem, rs1_eq_wb, rs2_eq_mem, rs2_eq_wb;
// logic rs1_valid, rs2_valid;

// assign rs1_valid = (rs1_EX != 0);
// assign rs2_valid = (rs2_EX != 0);
// assign rs1_eq_mem = (rs1_EX == wd_MEM);
// assign rs1_eq_wb = (rs1_EX == wd_WB);
// assign rs2_eq_mem = (rs2_EX == wd_MEM);
// assign rs2_eq_wb = (rs2_EX == wd_WB);

// // Flattened forwarding logic
// assign forwardA[1] = rs1_eq_mem & reg_write_MEM & rs1_valid;
// assign forwardA[0] = rs1_eq_wb & reg_write_WB & rs1_valid & ~forwardA[1];

// assign forwardB[1] = rs2_eq_mem & reg_write_MEM & rs2_valid;
// assign forwardB[0] = rs2_eq_wb & reg_write_WB & rs2_valid & ~forwardB[1];
assign forwardA=(((rs1_EX==wd_MEM)&reg_write_MEM)&rs1_EX!=0)?2'b10:(((rs1_EX==wd_WB)&reg_write_WB)&rs1_EX!=0)?2'b01:2'b00;
assign forwardB=(((rs2_EX==wd_MEM)&reg_write_MEM)&rs2_EX!=0)?2'b10:(((rs2_EX==wd_WB)&reg_write_WB)&rs2_EX!=0)?2'b01:2'b00;
assign load_stall=mem_read_EX&((rs1_ID==wd_EX)|(rs2_ID==wd_EX));
assign stall=load_stall|ALUbusy;
assign flushID=branch_taken|trapped;
assign flushEX=branch_taken|load_stall|trapped;
assign flushMEM=trapped;
// TODO Data from an ADD/i before a store shouldnt be forwarded if rs1==wd ex addi x1 x0 5 sw x1 0(x2)
endmodule