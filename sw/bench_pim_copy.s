    .include "sw/pim.inc"
    .globl _start
_start:
    addi x10, x0, 256        # source row (array A, row 2)
    addi x11, x0, 512        # destination row (array C, row 4)
    pim_copy x11, x10        # copy the whole row inside the memory
    addi x30, x0, 1000
    sw   x30, 0(x0)          # report "finished"
halt:
    beq  x0, x0, halt
