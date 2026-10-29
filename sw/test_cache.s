    .globl _start
_start:
    addi x1, x0, 256         # 0x100
    addi x2, x0, 11
    addi x3, x0, 22
    sw   x2, 0(x1)           # stores to a line that is not cached
    sw   x3, 4(x1)

    addi x31, x0, 1          # 1: a load miss must return what the stores wrote
    lw   x4, 0(x1)
    bne  x4, x2, fail

    addi x31, x0, 2          # 2: the next word of the same line (a hit)
    lw   x5, 4(x1)
    bne  x5, x3, fail

    addi x31, x0, 3          # 3: a store to a cached line must update the cache
    addi x6, x0, 33
    sw   x6, 0(x1)
    lw   x7, 0(x1)           # must see 33, not the stale 11
    bne  x7, x6, fail

    addi x31, x0, 4          # 4: conflict: 0x200 maps to the same line as 0x100
    addi x8, x0, 512
    addi x9, x0, 44
    sw   x9, 0(x8)
    lw   x10, 0(x8)          # miss, replaces the line holding 0x100
    bne  x10, x9, fail

    addi x31, x0, 5          # 5: 0x100 was evicted; memory must still hold 33
    lw   x11, 0(x1)
    bne  x11, x6, fail

    addi x31, x0, 6          # 6: the other word of that line is still 22
    lw   x12, 4(x1)
    bne  x12, x3, fail

pass:
    addi x30, x0, 1000
    sw   x30, 0(x0)
    beq  x0, x0, halt
fail:
    sw   x31, 0(x0)
halt:
    beq  x0, x0, halt
