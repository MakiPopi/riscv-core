#!/bin/sh
# Assemble and run every sw/test_*.s on the CPU.
mkdir -p sim
iverilog -o sim/cpu_tb rtl/alu.v rtl/regfile.v rtl/decoder.v rtl/imem.v rtl/dmem.v rtl/cpu.v tb/cpu_tb.v || exit 1
status=0
for src in sw/test_*.s; do
    name=$(basename "$src" .s)
    sw/asm2hex.sh "$src" || exit 1
    result=$(vvp sim/cpu_tb +prog=sw/$name.hex | grep RESULT)
    echo "$name: $result"
    case "$result" in
        *PASS*) ;;
        *) status=1 ;;
    esac
done
exit $status
