`timescale 1ns/1ps
module top_tb_soc;
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
    top DUT(.*);
    // top_single_cycle DUT1(.*);

    // Clock generation
    initial begin
        forever #5 clk = ~clk;    ///#18.519 clk = ~clk; // 27 MHz clock (period ~37 ns)
    end
always @(posedge clk) begin
  if (mem_write_req && DataADDR == 32'h3FFC) begin  // Last word in DMEM
    test_result <= WriteData;
    $display("Test result written: 0x%08h", WriteData);
    if (WriteData == 32'hAA55AA55)
      $display("TEST PASSED!");
    else if (WriteData == 32'hFFFFFFFF)
      $display("TEST FAILED!");
  end
end
    // Simulation control
    initial begin
        $dumpfile("sim/top_tb_soc.vcd");
        $dumpvars(0, top_tb_soc);
        $display("Simulation started");
        //RISC V CPU TEST
        ///TEST LISTS
        #0 begin
            test_result=0;
            reset = 1;
        end
        #10 begin
            reset=0;
        end
        #100000 begin // Simulate for 1 ms
            // dump_dmem();
            // check_test_result();
            $display("Simulation finished at time %t", $time);
            $finish;
        end
    end
logic [31:0] test_result;

// Monitor the memory-mapped output port

    // Add this to your testbench
// task check_test_result;
//   logic [31:0] result_word;
//   integer result_addr;
  
//   begin
//     // Determine the approximate location of test_result+4
//     // With 1024 words in DMEM, test_result should be near the beginning
//     // Our code places it after test_data (10 words), so around index 11
//     result_addr = 11;  // This is an approximation, adjust based on your layout
    
//     // Reconstruct the word at this address
//     result_word = 0;
//     for (int j = 0; j < COL_NUM; j = j + 1) begin
//       result_word = result_word | (MEMORY[result_addr][j] << (j * COL_WIDTH));
//     end
    
//     if (result_word == 32'hAA55AA55) begin
//       $display("TEST PASSED! All instructions verified successfully.");
//     end else if (result_word == 32'hFFFFFFFF) begin
//       // Get the test number that failed
//       result_addr = 10;  // test_result address
//       result_word = 0;
//       for (int j = 0; j < COL_NUM; j = j + 1) begin
//         result_word = result_word | (MEMORY[result_addr][j] << (j * COL_WIDTH));
//       end
//       $display("TEST FAILED! Failed at test number %0d", result_word);
//     end else begin
//       $display("Test result not found at expected location. Check memory dump.");
//     end
//   end
// endtask

// integer fd;
// integer i;

// Call this at the end of your simulation
// Add to your testbench
// task dump_dmem;
//   integer fd;
//   integer i, j;
//   logic [31:0] word_value;
  
//   begin
//     fd = $fopen("dmem_dump.txt", "w");
    
//     for (i = 0; i < 2**DEPTH; i = i + 1) begin
//       // Reconstruct the full word from columns
//       word_value = 0;
//       for (j = 0; j < COL_NUM; j = j + 1) begin
//         word_value = word_value | (MEMORY[i][j] << (j * COL_WIDTH));
//       end
      
//       $fdisplay(fd, "DMEM[%0d] = 0x%08h", i, word_value);
      
//       // Print the test result when we reach it (near address 0x28-0x2C)
//       if (i == 10 || i == 11) begin  // Assuming test_result is around these indices
//         $display("Possible test result at DMEM[%0d] = 0x%08h", i, word_value);
//       end
//     end
    
//     $fclose(fd);
//     $display("DMEM dump completed to dmem_dump.txt");
//   end
// endtask
endmodule