//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9.03 (64-bit) 
//Created Time: 2025-02-27 21:16:32
create_clock -name clk -period 5 -waveform {0 2.5} [get_ports {clk}] -add
// Allow 2 cycles for certain non-critical operations
//set_multicycle_path 2 -setup -from [get_pins EX_MEM_reg/REGISTER*] -to [get_pins MEM_WB_reg/REGISTER*] -through [get_pins LSU_MEM/*]