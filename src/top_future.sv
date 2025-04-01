//future reference for the top module
// `timescale 1ns/1ps
// module top(
//     // Core system signals
//     input  logic        clk_in,       // External clock input (27MHz on Tang Nano 20K)
//     input  logic        rst_n,        // Active-low reset from board button
    
//     // UART Interface
//     output logic        uart_tx,      // UART transmit pin
//     input  logic        uart_rx,      // UART receive pin
    
//     // Debug LEDs
//     output logic [5:0]  leds,         // 6 onboard LEDs for status
    
//     // Optional: LCD interface (ST7789 display on Tang Nano 20K)
//     output logic        lcd_clk,      // LCD clock
//     output logic        lcd_cs,       // LCD chip select
//     output logic        lcd_rs,       // LCD register select (data/command)
//     output logic        lcd_reset,    // LCD reset
//     output logic        lcd_data      // LCD data (SPI)
// );

//     // Internal signals
//     logic        clk;                 // System clock
//     logic        reset;               // Active-high reset
//     logic [31:0] instruction;
//     logic [31:0] pc;
//     logic [31:0] WriteData, ReadData, DataADDR;
//     logic [3:0]  mem_write_req;
//     logic        mem_read_req;
//     logic        missaligned_exception, misaligned_load_exception;
//     logic        misaligned_store_exception, ill_instr_exception;

//     // Debug signals for UART/display
//     logic [31:0] debug_reg;           // Register to show on display/UART
//     logic [2:0]  cpu_state;           // CPU state for status display
    
//     // =========================================================
//     // Clock and Reset Management
//     // =========================================================
    
//     // PLL for clock generation (27MHz to 48MHz)
//     Gowin_rPLL pll_inst(
//         .clkout(clk),                 // 48MHz output
//         .clkin(clk_in)                // 27MHz input
//     );
    
//     // Reset synchronization
//     logic reset_sync1, reset_sync2;
//     always_ff @(posedge clk) begin
//         reset_sync1 <= ~rst_n;        // Invert active-low to active-high
//         reset_sync2 <= reset_sync1;
//         reset <= reset_sync2;         // Double-registered reset
//     end
    
//     // =========================================================
//     // Core Instantiation
//     // =========================================================
    
//     pipelined_core PIPELINED_CORE(
//         .clk(clk),
//         .reset(reset),
//         .instruction(instruction),
//         .ReadData(ReadData),
//         .pc_out(pc),
//         .WriteData(WriteData),
//         .DataADDR(DataADDR),
//         .missaligned_exception(missaligned_exception),
//         .misaligned_load_exception(misaligned_load_exception),
//         .misaligned_store_exception(misaligned_store_exception),
//         .mem_write_req(mem_write_req),
//         .mem_read_req(mem_read_req),
//         .ill_instr_exception(ill_instr_exception)
//     );

//     // =========================================================
//     // Memory Instantiation
//     // =========================================================
    
//     // Instruction memory with proper constraints
//     (* ram_style = "block" *) iram IRAM(
//         .addr(pc),
//         .rd(instruction)
//     );
    
//     // Data memory with proper constraints
//     (* ram_style = "block" *) ram RAM(
//         .clk(clk),
//         .we(mem_write_req),
//         .addr(DataADDR),
//         .DATA_IN(WriteData),
//         .DATA_OUT(ReadData)
//     );
    
//     // =========================================================
//     // UART Interface Module
//     // =========================================================
    
//     // UART parameters
//     localparam UART_CLK_FREQ = 48_000_000;  // 48MHz
//     localparam UART_BAUD_RATE = 115_200;    // 115.2kbps
    
//     // UART control and status
//     logic       uart_tx_busy;
//     logic       uart_tx_start;
//     logic [7:0] uart_tx_data;
//     logic       uart_rx_valid;
//     logic [7:0] uart_rx_data;
    
//     // UART transmitter
//     uart_tx #(
//         .CLK_FREQ(UART_CLK_FREQ),
//         .BAUD_RATE(UART_BAUD_RATE)
//     ) uart_tx_inst (
//         .clk(clk),
//         .reset(reset),
//         .tx_start(uart_tx_start),
//         .tx_data(uart_tx_data),
//         .tx_busy(uart_tx_busy),
//         .tx(uart_tx)
//     );
    
//     // UART receiver
//     uart_rx #(
//         .CLK_FREQ(UART_CLK_FREQ),
//         .BAUD_RATE(UART_BAUD_RATE)
//     ) uart_rx_inst (
//         .clk(clk),
//         .reset(reset),
//         .rx(uart_rx),
//         .rx_valid(uart_rx_valid),
//         .rx_data(uart_rx_data)
//     );
    
//     // =========================================================
//     // Debug and Status Output
//     // =========================================================
    
//     // Debug LEDs - show critical CPU status
//     assign leds[0] = ~reset;                      // On when not in reset
//     assign leds[1] = mem_read_req;               // On during memory read
//     assign leds[2] = |mem_write_req;             // On during memory write
//     assign leds[3] = missaligned_exception |     // On during any exception
//                      misaligned_load_exception |
//                      misaligned_store_exception |
//                      ill_instr_exception;
//     assign leds[4] = uart_tx_busy;               // On during UART transmission
//     assign leds[5] = uart_rx_valid;              // Pulses when UART receives data
    
//     // UART debug control - simple state machine
//     localparam UART_IDLE = 3'd0;
//     localparam UART_PC = 3'd1;
//     localparam UART_INSTR = 3'd2;
    
//     // Debug state control
//     always_ff @(posedge clk) begin
//         if (reset) begin
//             cpu_state <= UART_IDLE;
//             uart_tx_start <= 0;
//         end
//         else begin
//             // Default state
//             uart_tx_start <= 0;
            
//             // UART command reception
//             if (uart_rx_valid) begin
//                 case (uart_rx_data)
//                     "p": cpu_state <= UART_PC;     // 'p' = show PC
//                     "i": cpu_state <= UART_INSTR;  // 'i' = show instruction
//                     default: cpu_state <= UART_IDLE;
//                 endcase
                
//                 // Start transmission
//                 uart_tx_data <= uart_rx_data;      // Echo received byte
//                 uart_tx_start <= 1;
//             end
//         end
//     end

// endmodule

// // PLL Module for clock generation
// module Gowin_rPLL (
//     output clkout,
//     input clkin
// );
//     // For Tang Nano 20K: 27MHz in -> 48MHz out
//     RPLL #(
//         .FCLKIN("27"),
//         .IDIV_SEL(2),      // Input divider 
//         .FBDIV_SEL(3),     // Feedback divider
//         .ODIV_SEL(16),     // Output divider
//         .DYN_SDIV_SEL(2),  // Dynamic output divider
//         .PSDA_SEL("0000")  // Phase shift
//     ) rpll_inst (
//         .CLKOUT(clkout),
//         .CLKIN(clkin),
//         .LOCK_O(),
//         .RESET(1'b0),
//         .RESET_P(1'b0)
//     );
// endmodule

// // Simple UART TX module
// module uart_tx #(
//     parameter CLK_FREQ = 48_000_000,
//     parameter BAUD_RATE = 115_200
// )(
//     input  logic       clk,
//     input  logic       reset,
//     input  logic       tx_start,
//     input  logic [7:0] tx_data,
//     output logic       tx_busy,
//     output logic       tx
// );
//     // UART TX logic would go here
//     // Simplified for brevity
// endmodule

// // Simple UART RX module
// module uart_rx #(
//     parameter CLK_FREQ = 48_000_000,
//     parameter BAUD_RATE = 115_200
// )(
//     input  logic       clk,
//     input  logic       reset,
//     input  logic       rx,
//     output logic       rx_valid,
//     output logic [7:0] rx_data
// );
//     // UART RX logic would go here
//     // Simplified for brevity
// endmodule