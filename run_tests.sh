#!/bin/sh
# Assemble every sw/test_*.s and run it at several memory latencies.
# Override the list with:  LATENCIES="0 20" ./run_tests.sh
mkdir -p sim
iverilog -o sim/cpu_tb rtl/alu.v rtl/regfile.v rtl/decoder.v rtl/imem.v rtl/dmem.v rtl/cpu.v tb/cpu_tb.v || exit 1
status=0
for src in sw/test_*.s; do
    name=$(basename "$src" .s)
    sw/asm2hex.sh "$src" || exit 1
    for lat in ${LATENCIES:-0 3 10}; do
        result=$(vvp sim/cpu_tb +prog=sw/$name.hex +latency=$lat | grep RESULT)
        echo "$name (latency $lat): $result"
        case "$result" in
            *PASS*) ;;
            *) status=1 ;;
        esac
    done
done
exit $status
