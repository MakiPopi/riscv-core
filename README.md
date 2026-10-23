# riscv-core

A small RISC-V (RV32I subset) processor written in Verilog, built from scratch
as a learning project in computer architecture. The long-term goal is to use it
to study how memory-system design affects performance.

## Status

- [x] ALU, register file, instruction decoder (each with a unit testbench)
- [x] Single-cycle core: R/I-type ALU instructions, `lw`, `sw`, `beq`, `bne`
- [x] Self-checking assembly test programs
- [ ] Memory latency model, cycle and instruction counters
- [ ] Data cache
- [ ] Custom instruction driving a memory-side unit
- [ ] Benchmarks and evaluation

## Requirements

- Icarus Verilog (`iverilog`, `vvp`)
- GNU make
- RISC-V binutils: `sudo apt install binutils-riscv64-unknown-elf`

## Running the tests

    make            # all unit testbenches and all assembly tests
    make tests      # assembly tests only

Each assembly test (`sw/test_*.s`) checks its own results. It writes `1000` to
memory word 0 if every check passes, or the number of the failing check
otherwise. `run_tests.sh` assembles each program, runs it, and reports PASS or
FAIL.

To run one program by hand:

    sw/asm2hex.sh sw/test_alu.s
    iverilog -o sim/cpu_tb rtl/*.v tb/cpu_tb.v
    vvp sim/cpu_tb +prog=sw/test_alu.hex

## Layout

- `rtl/`  hardware design (Verilog)
- `tb/`   testbenches
- `sw/`   assembly programs and the assembler script
- `docs/` notes and results

## Known limitations

- Not implemented: `lui`, `auipc`, `jal`, `jalr`, `blt`, `bge`, `bltu`, `bgeu`,
  byte and halfword loads and stores.
- The decoder accepts some invalid encodings (it does not check `funct7` on
  R-type instructions) and treats unsupported branch types as never taken.
- Memory is 1 KB of instructions and 1 KB of data, with no memory-latency
  model yet.
