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
- [x] Assembly toolchain and self-checking test programs
- [x] Configurable memory latency and performance counters
- [x] Baseline benchmarks: CPU copy loop and AND loop, both verified
- [x] Direct-mapped write-through data cache (own testbench, integrated in the CPU)
- [x] Ideal store buffer option, to bound the best case of the CPU baseline
- [ ] Memory-side unit and custom instruction
- [ ] Cache consistency with the memory-side unit
- [ ] Parameter sweeps, plots and written report

## Requirements

- Icarus Verilog (`iverilog`, `vvp`)
- GNU make
- RISC-V binutils: `sudo apt install binutils-riscv64-unknown-elf`

## Running the tests

    make            # unit testbenches (ALU, register file, decoder, cache) and CPU tests
    make tests      # CPU tests only

Each assembly test (`sw/test_*.s`) checks its own results: it writes 1000 to
memory word 0 if every check passes, or the number of the failing check
otherwise. `run_tests.sh` runs every test for every combination of cache
(off/on), store mode (normal/ideal) and latency (0, 3, 10), because timing bugs
can pass in one configuration and fail in another. It prints failures and a
summary; set VERBOSE=1 to see every run.

## Running the benchmarks

    ./run_bench.sh

or one run by hand:

    sw/asm2hex.sh sw/bench_copy.s
    vvp sim/cpu_tb +prog=sw/bench_copy.hex +data=sw/data_copy32.hex +verify_copy +latency=10 +cache=1

Options:

- `+prog=FILE`      program to load (hex, one 32-bit word per line)
- `+data=FILE`      optional preload of data memory
- `+latency=N`      extra cycles a memory access waits (default 0)
- `+cache=0|1`      data cache off or on (default off)
- `+ideal_store=0|1` stores never wait (default off)
- `+verify_copy`, `+verify_and`  check the benchmark result after the run

Run `make tests` first, which compiles the simulator into `sim/cpu_tb`.

## Memory model

A single-cycle core. Every instruction completes in one cycle, except memory
accesses that have to wait. While waiting, the CPU freezes: the PC holds and
nothing is written. Instruction fetch is ideal and never waits.

- No cache: every load and store waits `latency` cycles.
- Cache (`+cache=1`): direct-mapped, 16 lines of 4 words (256 bytes),
  write-through, no write-allocate. A load hit does not wait. A load miss waits
  `latency` cycles and then installs the whole line (modelled as one wide
  transfer; burst time is not modelled). A store waits `latency` cycles, writes
  memory, and updates the cache only if the line is already there.
- Ideal store buffer (`+ideal_store=1`): stores never wait. This models an
  infinitely deep store buffer with no delay and is the best case for the CPU.
  Real hardware lies between the normal and ideal settings, so results are
  reported for both.

With these rules:

    cycles = instructions + (accesses that wait) x latency

Data layout used by the benchmarks (byte addresses): result word at 0,
array A at 0x100, array B at 0x180, output array C at 0x200. A and B occupy
different cache lines.

## Results so far

CPU copy loop (32 words) and AND loop (32 words), normal stores:

| Benchmark | Latency | No cache | Cache | Speedup |
|-----------|---------|----------|-------|---------|
| copy      | 10      | 847      | 607   | 1.40x   |
| copy      | 50      | 3447     | 2247  | 1.53x   |
| and       | 10      | 1264     | 784   | 1.61x   |
| and       | 50      | 5144     | 2744  | 1.87x   |

All counts match the formula above exactly. With normal stores, 33 of the
accesses that still wait are stores (33 of 41 for the copy, 33 of 49 for the
AND), which limits what the cache can do.

With the ideal store buffer (stores never wait), same benchmarks:

| Benchmark | Latency | No cache | Cache | Speedup |
|-----------|---------|----------|-------|---------|
| copy      | 10      | 517      | 277   | 1.87x   |
| copy      | 50      | 1797     | 597   | 3.01x   |
| and       | 10      | 934      | 454   | 2.06x   |
| and       | 50      | 3494     | 1094  | 3.19x   |

A real store buffer would land between the two tables. With the cache on, the
gap between the normal and ideal store modes is 1.7x to 3.8x, which is the
uncertainty the choice of CPU baseline introduces.

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
- The normal store mode has no write buffer, which is pessimistic. The ideal
  store mode is optimistic. The truth for a real design lies between them.
- Cycle counts exclude the reset cycles.
