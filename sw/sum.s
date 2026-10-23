    .globl _start
_start:
    addi x1, x0, 5        # counter = 5
    addi x2, x0, 0        # sum = 0
loop:
    add  x2, x2, x1       # sum += counter
    addi x1, x1, -1       # counter--
    bne  x1, x0, loop     # repeat until counter == 0
    sw   x2, 0(x0)        # mem[0] = sum
    lw   x3, 0(x0)        # x3 = mem[0]
halt:
    beq  x0, x0, halt     # branch to itself forever
