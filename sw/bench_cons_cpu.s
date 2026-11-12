    .include "sw/pim.inc"
    .globl _start
_start:
    addi x1, x0, 256
    addi x2, x0, 384
    lw   x4, 0(x1)
    sw   x4, 0(x2)
    lw   x4, 4(x1)
    sw   x4, 4(x2)
    lw   x4, 8(x1)
    sw   x4, 8(x2)
    lw   x4, 12(x1)
    sw   x4, 12(x2)
    lw   x4, 16(x1)
    sw   x4, 16(x2)
    lw   x4, 20(x1)
    sw   x4, 20(x2)
    lw   x4, 24(x1)
    sw   x4, 24(x2)
    lw   x4, 28(x1)
    sw   x4, 28(x2)
    lw   x4, 32(x1)
    sw   x4, 32(x2)
    lw   x4, 36(x1)
    sw   x4, 36(x2)
    lw   x4, 40(x1)
    sw   x4, 40(x2)
    lw   x4, 44(x1)
    sw   x4, 44(x2)
    lw   x4, 48(x1)
    sw   x4, 48(x2)
    lw   x4, 52(x1)
    sw   x4, 52(x2)
    lw   x4, 56(x1)
    sw   x4, 56(x2)
    lw   x4, 60(x1)
    sw   x4, 60(x2)
    lw   x4, 64(x1)
    sw   x4, 64(x2)
    lw   x4, 68(x1)
    sw   x4, 68(x2)
    lw   x4, 72(x1)
    sw   x4, 72(x2)
    lw   x4, 76(x1)
    sw   x4, 76(x2)
    lw   x4, 80(x1)
    sw   x4, 80(x2)
    lw   x4, 84(x1)
    sw   x4, 84(x2)
    lw   x4, 88(x1)
    sw   x4, 88(x2)
    lw   x4, 92(x1)
    sw   x4, 92(x2)
    lw   x4, 96(x1)
    sw   x4, 96(x2)
    lw   x4, 100(x1)
    sw   x4, 100(x2)
    lw   x4, 104(x1)
    sw   x4, 104(x2)
    lw   x4, 108(x1)
    sw   x4, 108(x2)
    lw   x4, 112(x1)
    sw   x4, 112(x2)
    lw   x4, 116(x1)
    sw   x4, 116(x2)
    lw   x4, 120(x1)
    sw   x4, 120(x2)
    lw   x4, 124(x1)
    sw   x4, 124(x2)
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
