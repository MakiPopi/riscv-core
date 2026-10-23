    .globl _start
_start:
    addi x1, x0, 5
    addi x2, x0, 0
loop:
    add  x2, x2, x1
    addi x1, x1, -1
    bne  x1, x0, loop
    sw   x2, 4(x0)          # store the sum in word 1
    lw   x3, 4(x0)          # read it back

    addi x4,  x0, 15        # expected value
    addi x31, x0, 1         # check 1: the sum is 15
    bne  x2, x4, fail
    addi x31, x0, 2         # check 2: the value read back from memory is 15
    bne  x3, x4, fail

pass:
    addi x30, x0, 1000
    sw   x30, 0(x0)         # report success
    beq  x0, x0, halt
fail:
    sw   x31, 0(x0)         # report which check failed
halt:
    beq  x0, x0, halt
