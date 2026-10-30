SIM = sim

all: alu regfile decoder cache dmem tests

alu:
	iverilog -o $(SIM)/alu_tb rtl/alu.v tb/alu_tb.v
	vvp $(SIM)/alu_tb

regfile:
	iverilog -o $(SIM)/regfile_tb rtl/regfile.v tb/regfile_tb.v
	vvp $(SIM)/regfile_tb

decoder:
	iverilog -o $(SIM)/decoder_tb rtl/decoder.v tb/decoder_tb.v
	vvp $(SIM)/decoder_tb

cache:
	iverilog -o $(SIM)/cache_tb rtl/cache.v rtl/dmem.v tb/cache_tb.v
	vvp $(SIM)/cache_tb

dmem:
	iverilog -o $(SIM)/dmem_tb rtl/dmem.v tb/dmem_row_tb.v
	vvp $(SIM)/dmem_tb

tests:
	./run_tests.sh

clean:
	rm -f $(SIM)/*

.PHONY: all alu regfile decoder cache dmem tests clean
