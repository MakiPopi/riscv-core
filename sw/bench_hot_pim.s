    .include "sw/pim.inc"
    .globl _start
_start:
    addi x1, x0, 256
    addi x2, x0, 384
    addi x5, x0, 0
    lw   x6, 0(x2)
    add  x5, x5, x6
    lw   x6, 4(x2)
    add  x5, x5, x6
    lw   x6, 8(x2)
    add  x5, x5, x6
    lw   x6, 12(x2)
    add  x5, x5, x6
    lw   x6, 16(x2)
    add  x5, x5, x6
    lw   x6, 20(x2)
    add  x5, x5, x6
    lw   x6, 24(x2)
    add  x5, x5, x6
    lw   x6, 28(x2)
    add  x5, x5, x6
    lw   x6, 32(x2)
    add  x5, x5, x6
    lw   x6, 36(x2)
    add  x5, x5, x6
    lw   x6, 40(x2)
    add  x5, x5, x6
    lw   x6, 44(x2)
    add  x5, x5, x6
    lw   x6, 48(x2)
    add  x5, x5, x6
    lw   x6, 52(x2)
    add  x5, x5, x6
    lw   x6, 56(x2)
    add  x5, x5, x6
    lw   x6, 60(x2)
    add  x5, x5, x6
    lw   x6, 64(x2)
    add  x5, x5, x6
    lw   x6, 68(x2)
    add  x5, x5, x6
    lw   x6, 72(x2)
    add  x5, x5, x6
    lw   x6, 76(x2)
    add  x5, x5, x6
    lw   x6, 80(x2)
    add  x5, x5, x6
    lw   x6, 84(x2)
    add  x5, x5, x6
    lw   x6, 88(x2)
    add  x5, x5, x6
    lw   x6, 92(x2)
    add  x5, x5, x6
    lw   x6, 96(x2)
    add  x5, x5, x6
    lw   x6, 100(x2)
    add  x5, x5, x6
    lw   x6, 104(x2)
    add  x5, x5, x6
    lw   x6, 108(x2)
    add  x5, x5, x6
    lw   x6, 112(x2)
    add  x5, x5, x6
    lw   x6, 116(x2)
    add  x5, x5, x6
    lw   x6, 120(x2)
    add  x5, x5, x6
    lw   x6, 124(x2)
    add  x5, x5, x6
    pim_copy x2, x1
    addi x5, x0, 0
    lw   x6, 0(x2)
    add  x5, x5, x6
    lw   x6, 4(x2)
    add  x5, x5, x6
    lw   x6, 8(x2)
    add  x5, x5, x6
    lw   x6, 12(x2)
    add  x5, x5, x6
    lw   x6, 16(x2)
    add  x5, x5, x6
    lw   x6, 20(x2)
    add  x5, x5, x6
    lw   x6, 24(x2)
    add  x5, x5, x6
    lw   x6, 28(x2)
    add  x5, x5, x6
    lw   x6, 32(x2)
    add  x5, x5, x6
    lw   x6, 36(x2)
    add  x5, x5, x6
    lw   x6, 40(x2)
    add  x5, x5, x6
    lw   x6, 44(x2)
    add  x5, x5, x6
    lw   x6, 48(x2)
    add  x5, x5, x6
    lw   x6, 52(x2)
    add  x5, x5, x6
    lw   x6, 56(x2)
    add  x5, x5, x6
    lw   x6, 60(x2)
    add  x5, x5, x6
    lw   x6, 64(x2)
    add  x5, x5, x6
    lw   x6, 68(x2)
    add  x5, x5, x6
    lw   x6, 72(x2)
    add  x5, x5, x6
    lw   x6, 76(x2)
    add  x5, x5, x6
    lw   x6, 80(x2)
    add  x5, x5, x6
    lw   x6, 84(x2)
    add  x5, x5, x6
    lw   x6, 88(x2)
    add  x5, x5, x6
    lw   x6, 92(x2)
    add  x5, x5, x6
    lw   x6, 96(x2)
    add  x5, x5, x6
    lw   x6, 100(x2)
    add  x5, x5, x6
    lw   x6, 104(x2)
    add  x5, x5, x6
    lw   x6, 108(x2)
    add  x5, x5, x6
    lw   x6, 112(x2)
    add  x5, x5, x6
    lw   x6, 116(x2)
    add  x5, x5, x6
    lw   x6, 120(x2)
    add  x5, x5, x6
    lw   x6, 124(x2)
    add  x5, x5, x6
halt:
    beq  x0, x0, halt
