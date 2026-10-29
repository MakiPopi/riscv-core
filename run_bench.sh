#!/bin/sh
# Run each benchmark with the cache off and on, at several memory latencies.
# Override the latencies with:  LATENCIES="0 100" ./run_bench.sh
mkdir -p sim
iverilog -o sim/cpu_tb rtl/alu.v rtl/regfile.v rtl/decoder.v rtl/imem.v rtl/dmem.v rtl/cache.v rtl/cpu.v tb/cpu_tb.v || exit 1
sw/asm2hex.sh sw/bench_copy.s || exit 1
sw/asm2hex.sh sw/bench_and.s || exit 1
for cache in 0 1; do
    for lat in ${LATENCIES:-0 10 50}; do
        echo "copy cache $cache latency $lat: $(vvp sim/cpu_tb +prog=sw/bench_copy.hex +data=sw/data_copy32.hex +verify_copy +latency=$lat +cache=$cache | grep RESULT)"
        echo "and  cache $cache latency $lat: $(vvp sim/cpu_tb +prog=sw/bench_and.hex +data=sw/data_and32.hex +verify_and +latency=$lat +cache=$cache | grep RESULT)"
    done
done
