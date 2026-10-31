    .include "sw/pim.inc"
    .globl _start
_start:
    # x5 = 0x01010101, the step between consecutive words
    addi x5, x0, 1
    slli x6, x5, 8
    or   x5, x5, x6          # 0x00000101
    slli x6, x5, 16
    or   x5, x5, x6          # 0x01010101

    # fill row 2 (0x100..0x17F) with word j = (64+j) * 0x01010101
    # and row 1 (0x080..0x0FF) with word j = (32+j) * 0x01010101
    addi x1, x0, 256
    addi x2, x0, 128
    slli x6, x5, 6           # first value for row 2
    slli x7, x5, 5           # first value for row 1
    addi x3, x0, 32
fill:
    sw   x6, 0(x1)
    sw   x7, 0(x2)
    add  x6, x6, x5
    add  x7, x7, x5
    addi x1, x1, 4
    addi x2, x2, 4
    addi x3, x3, -1
    bne  x3, x0, fill

    # the three row operations
    addi x10, x0, 256        # row 2
    addi x11, x0, 512        # row 4
    addi x12, x0, 640        # row 5
    addi x13, x0, 128        # row 1
    pim_copy x11, x10        # row 4 = row 2
    pim_copy x12, x10        # row 5 = row 2
    pim_and  x12, x13        # row 5 = row 5 AND row 1  (= row 2 AND row 1)

    # check every word of every row involved
    addi x1, x0, 256         # row 2
    addi x2, x0, 128         # row 1
    addi x14, x0, 512        # row 4
    addi x15, x0, 640        # row 5
    slli x6, x5, 6           # expected row 2 word, advancing
    slli x7, x5, 5           # expected row 1 word, advancing
    addi x3, x0, 32
verify:
    addi x31, x0, 1          # check 1: row 4 is a copy of row 2
    lw   x20, 0(x14)
    bne  x20, x6, fail
    addi x31, x0, 2          # check 2: row 5 is row 2 AND row 1
    lw   x21, 0(x15)
    and  x22, x6, x7
    bne  x21, x22, fail
    addi x31, x0, 3          # check 3: source row 2 is unchanged
    lw   x23, 0(x1)
    bne  x23, x6, fail
    addi x31, x0, 4          # check 4: source row 1 is unchanged
    lw   x24, 0(x2)
    bne  x24, x7, fail
    add  x6, x6, x5
    add  x7, x7, x5
    addi x1, x1, 4
    addi x2, x2, 4
    addi x14, x14, 4
    addi x15, x15, 4
    addi x3, x3, -1
    bne  x3, x0, verify

pass:
    addi x30, x0, 1000
    sw   x30, 0(x0)
    beq  x0, x0, halt
fail:
    sw   x31, 0(x0)
halt:
    beq  x0, x0, halt
