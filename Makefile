SIM = sim

all: alu regfile decoder

alu:
	iverilog -o $(SIM)/alu_tb rtl/alu.v tb/alu_tb.v
	vvp $(SIM)/alu_tb

regfile:
	iverilog -o $(SIM)/regfile_tb rtl/regfile.v tb/regfile_tb.v
	vvp $(SIM)/regfile_tb

decoder:
	iverilog -o $(SIM)/decoder_tb rtl/decoder.v tb/decoder_tb.v
	vvp $(SIM)/decoder_tb

clean:
	rm -f $(SIM)/*

.PHONY: all alu regfile decoder clean
