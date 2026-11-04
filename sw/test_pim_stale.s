    .include "sw/pim.inc"
    .globl _start
_start:
    addi x10, x0, 256        # row 2
    addi x11, x0, 512        # row 4
    addi x2, x0, 77
    addi x5, x0, 88
    sw   x2, 0(x10)          # row 2, word 0 = 77
    sw   x5, 4(x10)          # row 2, word 1 = 88

    addi x31, x0, 1          # check 1: row 4 word 0 is 0 before the copy
    lw   x3, 0(x11)          # this load also puts the line into the cache
    bne  x3, x0, fail

    pim_copy x11, x10        # row 4 = row 2, done inside the memory

    addi x31, x0, 2          # check 2: row 4 word 0 must now be 77
    lw   x4, 0(x11)
    bne  x4, x2, fail
    addi x31, x0, 3          # check 3: word 1, in the same cache line, must be 88
    lw   x6, 4(x11)
    bne  x6, x5, fail

pass:
    addi x30, x0, 1000
    sw   x30, 0(x0)
    beq  x0, x0, halt
fail:
    sw   x31, 0(x0)
halt:
    beq  x0, x0, halt
