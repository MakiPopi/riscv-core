    .globl _start
_start:
    addi x1, x0, 8
    addi x2, x0, 77
    sw   x2, 8(x0)          # mem[8] = 77
    addi x31, x0, 1
    lw   x1, 0(x1)          # x1 = mem[x1]: destination is also the address register
    bne  x1, x2, fail
pass:
    addi x30, x0, 1000
    sw   x30, 0(x0)
    beq  x0, x0, halt
fail:
    sw   x31, 0(x0)
halt:
    beq  x0, x0, halt
