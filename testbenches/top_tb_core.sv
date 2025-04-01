`timescale 1ns/1ps
module top_tb_core;
    logic  clk = 0;
    logic reset=0;
    logic [31:0] instruction=0;
    logic [31:0] ReadData;
    logic [31:0] pc_out,DataADDR,WriteData;
    // logic mem_write,mem_read;
    logic missaligned_exception;
    logic misaligned_load_exception,misaligned_store_exception;
    logic mem_write_req,mem_read_req;
    logic ill_instr_exception;
    // Instantiate the DUT
    pipelined_core DUT(.*);

    // Clock generation
    initial begin
        forever #5 clk = ~clk;    ///#18.519 clk = ~clk; // 27 MHz clock (period ~37 ns)
    end

    // Simulation control
    initial begin
        $dumpfile("sim/top_tb_core.vcd");
        $dumpvars(0, top_tb_core);
        $display("Simulation started");
        //RISC V CPU TEST
        ///TEST LISTS
        /*RAM[0]  = 32'h00000013; // NOP (addi x0, x0, 0)
        RAM[1]  = 32'h00100093; // addi x1, x0, 1
        RAM[2]  = 32'h00208113; // addi x2, x1, 2
        RAM[3]  = 32'h00310193; // addi x3, x2, 3
        RAM[4]  = 32'h00418213; // addi x4, x3, 4
        RAM[5]  = 32'h00520293; // addi x5, x4, 5
        RAM[6]  = 32'h00628313; // addi x6, x5, 6
        RAM[7]  = 32'h00730393; // addi x7, x6, 7*/
        
        #0 begin
            reset = 1;
        end
        // #10 begin
        //     reset = 0;
        //     instruction = 32'h 00500113; // addi x2,x0,5
        // end
        // #10 begin
        //     instruction = 32'h00C00193; // addi x3,x0,12
        // end
        // #10 begin
        //     instruction = 32'hFF718393; // addi x7,x3,-9
        // end
        // #10 begin
        //     instruction = 32'h0023E233; // or x4,x7,x2
        // end
        // #10 begin
        //     instruction = 32'h0041F2B3; // and x5,x3,x4
        // end
        // #10 begin
        //     instruction = 32'h004282B3; // add x5,x5,x4
        // end
        // #10 begin
        //     instruction = 32'h0041A233; // slt x4,x3,x4
        // end
        
        //make x1 and x2 equal
        #10 begin
            reset = 0;
            instruction = 32'h00500093; // addi x1, x0 ,5
        end
        #10 begin
            reset = 0;
            instruction = 32'h00500113; // addi x2, x0 ,5
            ReadData = 32'h00000010;
        end
        // test BEQ
        // #10 begin
        //     reset = 0;
        //     instruction = 32'h3e208363; // beq x1,x2,998
        // end
        // #10 begin
        //     reset = 0;
        //     instruction = 32'h38309263; // bne x1,x3,900
        // end
        // #10 begin
        //     reset = 0;
        //     instruction = 32'h 00500113; // addi x2,x0,5
        // end
        // #10 begin
        //     instruction = 32'h384000ef; // jal x1, 900
        // end
        // #10 begin
        //     instruction = 32'h00064097; // auipc x1, 100
        // end
        // #10 begin
        //     instruction = 32'h000082e7; // jalr x5, 0(x1)
        // end
        #10 begin
            instruction = 32'h0000a283; // lw x5, 0(x1)
        end
        #1000 begin // Simulate for 1 ms
            $display("Simulation finished at time %t", $time);
            $finish;
        end
    end
endmodule