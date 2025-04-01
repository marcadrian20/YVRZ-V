`timescale 1ns/1ps
module top_tb_soc_single_cycle;
    logic  clk = 0;
    logic reset=0;
    logic [31:0] instruction;
    logic [31:0] ReadData;
    logic [31:0] pc,DataADDR,WriteData;
    // logic mem_write,mem_read;
    logic missaligned_exception;
    logic misaligned_load_exception,misaligned_store_exception;
    logic [3:0] mem_write_req;
    logic mem_read_req;
    logic ill_instr_exception;
    //////////////////////////

    // Instantiate the DUT
    top_single_cycle DUT(.*);
    // top_single_cycle DUT1(.*);

    // Clock generation
    initial begin
        forever #5 clk = ~clk;    ///#18.519 clk = ~clk; // 27 MHz clock (period ~37 ns)
    end

    // Simulation control
    initial begin
        $dumpfile("sim/top_tb_soc_single_cycle.vcd");
        $dumpvars(0, top_tb_soc_single_cycle);
        $display("Simulation started");
        //RISC V CPU TEST
        ///TEST LISTS
        #0 begin
            reset = 1;
        end
        #10 begin
            reset=0;
        end
        #1000 begin // Simulate for 1 ms
            $display("Simulation finished at time %t", $time);
            $finish;
        end
    end
endmodule