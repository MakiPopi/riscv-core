# Fully unrolled AND of two 32-word rows (generated)
    .globl _start
_start:
    addi x1, x0, 256
    addi x2, x0, 384
    addi x3, x0, 512
    lw   x6, 0(x1)
    lw   x7, 0(x2)
    and  x8, x6, x7
    sw   x8, 0(x3)
    lw   x6, 4(x1)
    lw   x7, 4(x2)
    and  x8, x6, x7
    sw   x8, 4(x3)
    lw   x6, 8(x1)
    lw   x7, 8(x2)
    and  x8, x6, x7
    sw   x8, 8(x3)
    lw   x6, 12(x1)
    lw   x7, 12(x2)
    and  x8, x6, x7
    sw   x8, 12(x3)
    lw   x6, 16(x1)
    lw   x7, 16(x2)
    and  x8, x6, x7
    sw   x8, 16(x3)
    lw   x6, 20(x1)
    lw   x7, 20(x2)
    and  x8, x6, x7
    sw   x8, 20(x3)
    lw   x6, 24(x1)
    lw   x7, 24(x2)
    and  x8, x6, x7
    sw   x8, 24(x3)
    lw   x6, 28(x1)
    lw   x7, 28(x2)
    and  x8, x6, x7
    sw   x8, 28(x3)
    lw   x6, 32(x1)
    lw   x7, 32(x2)
    and  x8, x6, x7
    sw   x8, 32(x3)
    lw   x6, 36(x1)
    lw   x7, 36(x2)
    and  x8, x6, x7
    sw   x8, 36(x3)
    lw   x6, 40(x1)
    lw   x7, 40(x2)
    and  x8, x6, x7
    sw   x8, 40(x3)
    lw   x6, 44(x1)
    lw   x7, 44(x2)
    and  x8, x6, x7
    sw   x8, 44(x3)
    lw   x6, 48(x1)
    lw   x7, 48(x2)
    and  x8, x6, x7
    sw   x8, 48(x3)
    lw   x6, 52(x1)
    lw   x7, 52(x2)
    and  x8, x6, x7
    sw   x8, 52(x3)
    lw   x6, 56(x1)
    lw   x7, 56(x2)
    and  x8, x6, x7
    sw   x8, 56(x3)
    lw   x6, 60(x1)
    lw   x7, 60(x2)
    and  x8, x6, x7
    sw   x8, 60(x3)
    lw   x6, 64(x1)
    lw   x7, 64(x2)
    and  x8, x6, x7
    sw   x8, 64(x3)
    lw   x6, 68(x1)
    lw   x7, 68(x2)
    and  x8, x6, x7
    sw   x8, 68(x3)
    lw   x6, 72(x1)
    lw   x7, 72(x2)
    and  x8, x6, x7
    sw   x8, 72(x3)
    lw   x6, 76(x1)
    lw   x7, 76(x2)
    and  x8, x6, x7
    sw   x8, 76(x3)
    lw   x6, 80(x1)
    lw   x7, 80(x2)
    and  x8, x6, x7
    sw   x8, 80(x3)
    lw   x6, 84(x1)
    lw   x7, 84(x2)
    and  x8, x6, x7
    sw   x8, 84(x3)
    lw   x6, 88(x1)
    lw   x7, 88(x2)
    and  x8, x6, x7
    sw   x8, 88(x3)
    lw   x6, 92(x1)
    lw   x7, 92(x2)
    and  x8, x6, x7
    sw   x8, 92(x3)
    lw   x6, 96(x1)
    lw   x7, 96(x2)
    and  x8, x6, x7
    sw   x8, 96(x3)
    lw   x6, 100(x1)
    lw   x7, 100(x2)
    and  x8, x6, x7
    sw   x8, 100(x3)
    lw   x6, 104(x1)
    lw   x7, 104(x2)
    and  x8, x6, x7
    sw   x8, 104(x3)
    lw   x6, 108(x1)
    lw   x7, 108(x2)
    and  x8, x6, x7
    sw   x8, 108(x3)
    lw   x6, 112(x1)
    lw   x7, 112(x2)
    and  x8, x6, x7
    sw   x8, 112(x3)
    lw   x6, 116(x1)
    lw   x7, 116(x2)
    and  x8, x6, x7
    sw   x8, 116(x3)
    lw   x6, 120(x1)
    lw   x7, 120(x2)
    and  x8, x6, x7
    sw   x8, 120(x3)
    lw   x6, 124(x1)
    lw   x7, 124(x2)
    and  x8, x6, x7
    sw   x8, 124(x3)
    addi x30, x0, 1000
    sw   x30, 0(x0)
halt:
    beq  x0, x0, halt
