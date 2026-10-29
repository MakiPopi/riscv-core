#!/bin/sh
# Assemble every sw/test_*.s and run it with the cache off and on,
# at several memory latencies.
# Override the latencies with:  LATENCIES="0 20" ./run_tests.sh
mkdir -p sim
iverilog -o sim/cpu_tb rtl/alu.v rtl/regfile.v rtl/decoder.v rtl/imem.v rtl/dmem.v rtl/cache.v rtl/cpu.v tb/cpu_tb.v || exit 1
status=0
for src in sw/test_*.s; do
    name=$(basename "$src" .s)
    sw/asm2hex.sh "$src" || exit 1
    for cache in 0 1; do
        for lat in ${LATENCIES:-0 3 10}; do
            result=$(vvp sim/cpu_tb +prog=sw/$name.hex +latency=$lat +cache=$cache | grep RESULT)
            echo "$name (cache $cache, latency $lat): $result"
            case "$result" in
                *PASS*) ;;
                *) status=1 ;;
            esac
        done
    done
done
exit $status
