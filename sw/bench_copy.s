    .globl _start
_start:
    addi x1, x0, 256        # source address (word 64)
    addi x2, x0, 512        # destination address (word 128)
    addi x3, x0, 32         # number of words left to copy
loop:
    lw   x4, 0(x1)          # read one word
    sw   x4, 0(x2)          # write it
    addi x1, x1, 4          # advance both pointers by one word
    addi x2, x2, 4
    addi x3, x3, -1
    bne  x3, x0, loop
    addi x30, x0, 1000
    sw   x30, 0(x0)         # report "finished"
halt:
    beq  x0, x0, halt
