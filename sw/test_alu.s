    .globl _start
_start:
    addi x1, x0, 12            # x1 = 1100 binary
    addi x2, x0, 10            # x2 = 1010 binary

    addi x31, x0, 1            # 1: add
    add  x3, x1, x2
    addi x4, x0, 22
    bne  x3, x4, fail

    addi x31, x0, 2            # 2: sub, positive result
    sub  x3, x1, x2
    addi x4, x0, 2
    bne  x3, x4, fail

    addi x31, x0, 3            # 3: sub, negative result
    sub  x3, x2, x1
    addi x4, x0, -2
    bne  x3, x4, fail

    addi x31, x0, 4            # 4: and (1100 & 1010 = 1000)
    and  x3, x1, x2
    addi x4, x0, 8
    bne  x3, x4, fail

    addi x31, x0, 5            # 5: or (1110)
    or   x3, x1, x2
    addi x4, x0, 14
    bne  x3, x4, fail

    addi x31, x0, 6            # 6: xor (0110)
    xor  x3, x1, x2
    addi x4, x0, 6
    bne  x3, x4, fail

    addi x5, x0, 2             # shift amount
    addi x31, x0, 7            # 7: sll, 12 << 2
    sll  x3, x1, x5
    addi x4, x0, 48
    bne  x3, x4, fail

    addi x31, x0, 8            # 8: srl, 12 >> 2
    srl  x3, x1, x5
    addi x4, x0, 3
    bne  x3, x4, fail

    addi x6, x0, 1
    slli x6, x6, 31            # x6 = 0x80000000, the most negative number

    addi x31, x0, 9            # 9: slt is signed, so 0x80000000 < 0
    slt  x3, x6, x0
    addi x4, x0, 1
    bne  x3, x4, fail

    addi x31, x0, 10           # 10: sltu is unsigned, so 0x80000000 < 0 is false
    sltu x3, x6, x0
    bne  x3, x0, fail

    addi x31, x0, 11           # 11: sra copies the sign bit in
    srai x3, x6, 4
    addi x4, x0, -1
    slli x4, x4, 27            # 0xF8000000
    bne  x3, x4, fail

    addi x31, x0, 12           # 12: srl fills with zeros
    srli x3, x6, 4
    addi x4, x0, 1
    slli x4, x4, 27            # 0x08000000
    bne  x3, x4, fail

    addi x31, x0, 13           # 13: slti with a negative immediate (-5 < -3)
    addi x7, x0, -5
    slti x3, x7, -3
    addi x4, x0, 1
    bne  x3, x4, fail

    addi x31, x0, 14           # 14: andi (1100 & 0110 = 0100)
    andi x3, x1, 6
    addi x4, x0, 4
    bne  x3, x4, fail

    addi x31, x0, 15           # 15: ori (1100 | 0011 = 1111)
    ori  x3, x1, 3
    addi x4, x0, 15
    bne  x3, x4, fail

    addi x31, x0, 16           # 16: xori (1100 ^ 0101 = 1001)
    xori x3, x1, 5
    addi x4, x0, 9
    bne  x3, x4, fail

    addi x31, x0, 17           # 17: beq is taken when the values are equal
    addi x8, x0, 7
    addi x9, x0, 7
    beq  x8, x9, beq_ok
    beq  x0, x0, fail          # reaching this line means the branch was not taken
beq_ok:

    addi x31, x0, 18           # 18: beq is not taken when the values differ
    addi x9, x0, 8
    beq  x8, x9, fail

    addi x31, x0, 19           # 19: writing x0 has no effect
    addi x0, x0, 5
    addi x3, x0, 1
    addi x4, x0, 1
    bne  x3, x4, fail

pass:
    addi x30, x0, 1000
    sw   x30, 0(x0)
    beq  x0, x0, halt
fail:
    sw   x31, 0(x0)
halt:
    beq  x0, x0, halt
