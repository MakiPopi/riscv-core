# riscv-core

A RISC-V (RV32I subset) processor written in Verilog, built from scratch as a
learning project in computer architecture.

## Status
- [x] ALU
- [x] Register file
- [x] Instruction decoder
- [x] Single-cycle core (R/I-type ALU ops, lw, sw, beq, bne)
- [ ] 5-stage pipeline
- [ ] Branch predictor
- [ ] Custom instruction + benchmarks

## Running the tests
Requires Icarus Verilog (`iverilog`) and `make`.

    make          # run all testbenches
    make cpu      # run the full-CPU test and write a waveform to sim/cpu.vcd

## Layout
- `rtl/` hardware design
- `tb/` testbenches
- `sw/` test programs (hex machine code)
- `docs/` notes and results
