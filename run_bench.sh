#!/bin/sh
# Run every benchmark for every combination of store mode (normal/ideal),
# cache (off/on) and memory latency.
# Override the latencies with:  LATENCIES="0 100" ./run_bench.sh
# Example filter:  ./run_bench.sh | grep "cache 1 ideal_store 1 latency 50"
mkdir -p sim
iverilog -o sim/cpu_tb rtl/alu.v rtl/regfile.v rtl/decoder.v rtl/imem.v rtl/dmem.v rtl/cache.v rtl/cpu.v tb/cpu_tb.v || exit 1

run() {   # arguments: benchmark name, data file, verification kind
    sw/asm2hex.sh sw/bench_$1.s || exit 1
    for ideal in 0 1; do
        for cache in 0 1; do
            for lat in ${LATENCIES:-0 10 50}; do
                echo "$1 cache $cache ideal_store $ideal latency $lat: $(vvp sim/cpu_tb +prog=sw/bench_$1.hex +data=sw/$2 +verify_$3 +latency=$lat +cache=$cache +ideal_store=$ideal | grep RESULT)"
            done
        done
    done
}

run copy          data_copy32.hex copy
run copy_unrolled data_copy32.hex copy
run pim_copy      data_copy32.hex copy
run and           data_and32.hex  and
run and_unrolled  data_and32.hex  and
run pim_and       data_and32.hex  and
run cons_cpu      data_copy32.hex sum
run cons_pim      data_copy32.hex sum
run hot_cpu       data_copy32.hex sum
run hot_pim       data_copy32.hex sum
