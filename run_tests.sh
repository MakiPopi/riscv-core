#!/bin/sh
# Assemble every sw/test_*.s and run it for every combination of
# cache (off/on), store mode (normal/ideal) and memory latency.
# Prints only failures plus a summary. Set VERBOSE=1 to print every run.
# Override the latencies with:  LATENCIES="0 20" ./run_tests.sh
mkdir -p sim
iverilog -o sim/cpu_tb rtl/alu.v rtl/regfile.v rtl/decoder.v rtl/imem.v rtl/dmem.v rtl/cache.v rtl/cpu.v tb/cpu_tb.v || exit 1
total=0
failed=0
for src in sw/test_*.s; do
    name=$(basename "$src" .s)
    sw/asm2hex.sh "$src" || exit 1
    for cache in 0 1; do
        for ideal in 0 1; do
            for lat in ${LATENCIES:-0 3 10}; do
                result=$(vvp sim/cpu_tb +prog=sw/$name.hex +latency=$lat +cache=$cache +ideal_store=$ideal | grep RESULT)
                total=$((total + 1))
                line="$name (cache $cache, ideal_store $ideal, latency $lat): $result"
                case "$result" in
                    *PASS*) if [ -n "$VERBOSE" ]; then echo "$line"; fi ;;
                    *) failed=$((failed + 1)); echo "$line" ;;
                esac
            done
        done
    done
done
echo "$((total - failed)) of $total runs passed"
[ "$failed" -eq 0 ]
