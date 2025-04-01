# Example Makefile for RV32GC core simulation

# Verilog files: include your core design files and the testbench
SRC = $(wildcard src/*.v) $(wildcard src/*.sv) $(wildcard src/gowin_rpll/*.v) $(wildcard D:/proiecte/gowin_IDE_fpga/Gowin/Gowin_V1.9.9.03_x64/IDE/simlib/gw2a/prim_sim.v)
# SRC= $(wildcard impl/pnr/*.vo) $(filter-out src/top.v, $(wildcard src/*.v)) $(wildcard src/gowin_rpll/*.v) $(wildcard D:/proiecte/gowin_IDE_fpga/Gowin/Gowin_V1.9.9.03_x64/IDE/simlib/gw2a/prim_sim.v)
TB  = testbenches/top_tb_soc.sv
# TB2 = testbenches/top_tb_soc_single_cycle.sv

# Output executable and VCD file names
SIM_OUT = sim/top_tb_soc.txt
# SIM_OUT2 = sim/top_tb_soc_single_cycle.txt
VCD_FILE = sim/top_tb_soc.vcd

# Icarus Verilog options
IVERILOG_OPTS = -g2012

# Default target: compile, simulate, and open waveform viewer
all: run sim

# Compile the design and testbench into an executable simulation file
run:
	@echo "Compiling design..."
	iverilog $(IVERILOG_OPTS) -o $(SIM_OUT) $(TB) $(SRC)
# iverilog $(IVERILOG_OPTS) -o $(SIM_OUT2) $(TB2) $(SRC)
# iverilog -o $(SIM_OUT) $(TB) $(SRC)
	@echo "Running simulation..."
	vvp $(SIM_OUT)
# vvp $(SIM_OUT2)

# Open the VCD file in GTKWave (if installed)
sim:
	@echo "Opening waveform..."
	gtkwave $(VCD_FILE)

# Clean generated files
clean:
	rm -f $(SIM_OUT) $(VCD_FILE)
