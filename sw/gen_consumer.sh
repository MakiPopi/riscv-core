#!/bin/sh
# Generates the four "consumer" benchmarks. Run from the project root:
#   sw/gen_consumer.sh
# Source row: row 2 (0x100). Destination row: row 3 (0x180).
# x5 accumulates the sum of the destination row.
gen() {   # arguments: name, copy mode (cpu|pim), warm up the destination first (0|1)
    awk -v mode="$2" -v warm="$3" 'BEGIN {
        print "    .include \"sw/pim.inc\""
        print "    .globl _start"
        print "_start:"
        print "    addi x1, x0, 256"
        print "    addi x2, x0, 384"
        if (warm) {
            print "    addi x5, x0, 0"
            for (i = 0; i < 32; i++) {
                printf "    lw   x6, %d(x2)\n", i * 4
                print  "    add  x5, x5, x6"
            }
        }
        if (mode == "cpu") {
            for (i = 0; i < 32; i++) {
                printf "    lw   x4, %d(x1)\n", i * 4
                printf "    sw   x4, %d(x2)\n", i * 4
            }
        } else {
            print "    pim_copy x2, x1"
        }
        print "    addi x5, x0, 0"
        for (i = 0; i < 32; i++) {
            printf "    lw   x6, %d(x2)\n", i * 4
            print  "    add  x5, x5, x6"
        }
        print "halt:"
        print "    beq  x0, x0, halt"
    }' > "sw/bench_$1.s"
}
gen cons_cpu cpu 0
gen cons_pim pim 0
gen hot_cpu  cpu 1
gen hot_pim  pim 1
