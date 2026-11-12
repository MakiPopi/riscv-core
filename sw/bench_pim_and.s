    .include "sw/pim.inc"
    .globl _start
_start:
    addi x10, x0, 256        # array A, row 2
    addi x11, x0, 384        # array B, row 3
    addi x12, x0, 512        # array C, row 4
    pim_copy x12, x10        # C = A
    pim_and  x12, x11        # C = C AND B, which is A AND B
    addi x30, x0, 1000
    sw   x30, 0(x0)          # report "finished"
halt:
    beq  x0, x0, halt
