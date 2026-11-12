#!/bin/sh
# Sweep every benchmark over cache (off/on), store mode (normal/ideal) and latency.
# Writes results/results.csv. Stops at the first run that does not PASS.
# Override the latencies with:  LATENCIES="0 10 50" ./run_sweep.sh
mkdir -p sim results
iverilog -o sim/cpu_tb rtl/alu.v rtl/regfile.v rtl/decoder.v rtl/imem.v rtl/dmem.v rtl/cache.v rtl/cpu.v tb/cpu_tb.v || exit 1
out=results/results.csv
echo "benchmark,cache,ideal_store,latency,cycles,instret,pim_ops,stalls,hits,misses" > $out

# extract one counter (name=NUMBER) from the RESULT line stored in $result
field() { echo "$result" | sed -n "s/.*$1=\([0-9]*\).*/\1/p"; }

sweep() {   # arguments: benchmark name, data file, verification kind
    sw/asm2hex.sh sw/bench_$1.s || exit 1
    for ideal in 0 1; do
        for cache in 0 1; do
            for lat in ${LATENCIES:-0 5 10 15 20 30 40 50 75 100}; do
                result=$(vvp sim/cpu_tb +prog=sw/bench_$1.hex +data=sw/$2 +verify_$3 +latency=$lat +cache=$cache +ideal_store=$ideal | grep RESULT)
                case "$result" in
                    *PASS*) ;;
                    *) echo "FAILED: $1 cache=$cache ideal_store=$ideal latency=$lat: $result"; exit 1 ;;
                esac
                echo "$1,$cache,$ideal,$lat,$(field cycles),$(field instret),$(field pim_ops),$(field stalls),$(field hits),$(field misses)" >> $out
            done
        done
    done
}

sweep copy          data_copy32.hex copy
sweep copy_unrolled data_copy32.hex copy
sweep pim_copy      data_copy32.hex copy
sweep and           data_and32.hex  and
sweep and_unrolled  data_and32.hex  and
sweep pim_and       data_and32.hex  and
sweep cons_cpu      data_copy32.hex sum
sweep cons_pim      data_copy32.hex sum
sweep hot_cpu       data_copy32.hex sum
sweep hot_pim       data_copy32.hex sum
echo "wrote $out ($(($(wc -l < $out) - 1)) runs)"
