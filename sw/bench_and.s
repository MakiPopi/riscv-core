    .globl _start
_start:
    addi x1, x0, 256        # x1 = pointer into A
    addi x2, x0, 384        # x2 = pointer into B
    addi x3, x0, 512        # x3 = pointer into C
    addi x5, x0, 32         # x5 = elements left
loop:
    lw   x6, 0(x1)          # x6 = A[i]
    lw   x7, 0(x2)          # x7 = B[i]
    and  x8, x6, x7         # x8 = A[i] & B[i]
    sw   x8, 0(x3)          # C[i] = x8
    addi x1, x1, 4          # advance the three pointers by one word
    addi x2, x2, 4
    addi x3, x3, 4
    addi x5, x5, -1         # one element done
    bne  x5, x0, loop       # repeat until none are left
    addi x30, x0, 1000
    sw   x30, 0(x0)         # report "finished"
halt:
    beq  x0, x0, halt
