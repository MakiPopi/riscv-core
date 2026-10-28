# riscv-core

A small RISC-V (RV32I subset) processor written in Verilog, built from scratch
as a learning project in computer architecture. It is the apparatus for a small
study of memory-system behavior.

## Research question

When does moving a bulk memory operation (copy, bitwise AND) out of the CPU and
into a memory-side unit pay off, and how does that depend on memory latency,
data size, and the cache in front of the core?

The idea of doing work near memory is well established in the processing-in-
memory literature. This project does not claim a new idea. It is a small,
reproducible evaluation on an RTL core built from scratch.

## Status

- [x] ALU, register file, instruction decoder (unit testbenches)
- [x] Single-cycle core: R/I-type ALU instructions, lw, sw, beq, bne
- [x] Assembly toolchain script and self-checking test programs
- [x] Configurable memory latency (stalls on every load/store)
- [x] Performance counters: cycles, instructions retired, memory operations
- [x] Baseline benchmark: CPU copy loop, verified
- [ ] Second baseline benchmark (bitwise AND of two arrays)
- [ ] Data cache (direct-mapped, write-through) with hit/miss counters
- [ ] Memory-side unit and custom instruction
- [ ] Cache consistency with the memory-side unit
- [ ] Parameter sweeps, plots and written report

## Requirements

- Icarus Verilog (`iverilog`, `vvp`)
- GNU make
- RISC-V binutils: `sudo apt install binutils-riscv64-unknown-elf`

## Running the tests

    make            # unit testbenches and all assembly tests
    make tests      # assembly tests only

Each assembly test (`sw/test_*.s`) checks its own results. It writes 1000 to
memory word 0 if every check passes, or the number of the failing check
otherwise. `run_tests.sh` runs every test at memory latencies 0, 3 and 10,
because stall bugs can pass at one latency and fail at another.

## Running a benchmark

    sw/asm2hex.sh sw/bench_copy.s
    vvp sim/cpu_tb +prog=sw/bench_copy.hex +data=sw/data_copy32.hex +verify_copy +latency=10

Run `make tests` first, which compiles the simulator into `sim/cpu_tb`.

- `+prog=FILE`   program to load (hex, one 32-bit word per line)
- `+data=FILE`   optional preload of data memory
- `+latency=N`   extra cycles every load/store waits (default 0)
- `+verify_copy` after the run, check that the copy is correct

`sw/data_copy32.hex` holds 64 zero words followed by 32 source words. Regenerate
it with:

    awk 'BEGIN { for (i=0; i<64; i++) print "00000000"; for (i=1; i<=32; i++) printf "%08x\n", i*3+1 }' > sw/data_copy32.hex

## How it works

A single-cycle core: every instruction completes in one cycle, except loads and
stores, which wait `latency` extra cycles. The CPU freezes while waiting (the
PC holds and nothing is written), then the instruction completes normally.
Instruction fetch is ideal and takes no extra time.

With this model:

    cycles = instructions + memory_ops x latency
    CPI    = 1 + (memory_ops / instructions) x latency

## Results so far

CPU copy loop, 32 words, no cache (197 instructions, 65 of them loads/stores):

| Latency | Cycles | CPI   |
|---------|--------|-------|
| 0       | 197    | 1.00  |
| 10      | 847    | 4.30  |
| 50      | 3447   | 17.50 |

These match the formula above exactly. Without a cache this is the worst case
for the CPU, so it exaggerates the cost of memory. A data cache is added before
any memory-side unit is compared against this baseline.

## Layout

- `rtl/`  hardware design (Verilog)
- `tb/`   testbenches
- `sw/`   assembly programs, data files and the assembler script
- `docs/` notes and results

## Known limitations

- Not implemented: lui, auipc, jal, jalr, blt, bge, bltu, bgeu, and byte or
  halfword loads and stores.
- The decoder accepts some invalid encodings (it does not check funct7 on
  R-type instructions) and treats unsupported branch types as never taken.
- Memory is 1 KB of instructions and 1 KB of data. Memory timing is a single
  latency number, not a DRAM model.
- Cycle counts exclude the reset cycles.
