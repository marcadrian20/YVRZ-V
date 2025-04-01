`timescale 1ns/1ps
module top_tb;
    logic  clk = 0;
    logic WE=0;
    logic [4:0] readPort1SEL=0;
    logic [4:0] readPort2SEL=0;
    logic [4:0] writePortSEL=0;
    logic [31:0] writePort=0;
    logic [31:0] readPort1,readPort2;

    // Instantiate the DUT
    regfile DUT(.*);

    // Clock generation
    initial begin
        forever #18.519 clk = ~clk; // 27 MHz clock (period ~37 ns)
    end

    // Simulation control
    initial begin
        $dumpfile("sim/top_tb.vcd");
        $dumpvars(0, top_tb);
        $display("Simulation started");
        #100 begin // Simulate for 100 ps
            WE = 1;
            readPort1SEL = 0;
            readPort2SEL = 0;
            writePortSEL = 1;
            writePort = 32'hFFFFFFFF;
        end
        #100 begin // Simulate for 100 ps
            WE = 0;
            readPort1SEL = 1;
            readPort2SEL = 0;
            writePortSEL = 0;
            writePort = 0;
        end
        #100 begin // Simulate for 100 ps
            WE = 0;
            readPort1SEL = 0;
            readPort2SEL = 1;
            writePortSEL = 0;
            writePort = 0;
        end
        #100000 begin // Simulate for 1 ms
            $display("Simulation finished at time %t", $time);
            $finish;
        end
    end
endmodule