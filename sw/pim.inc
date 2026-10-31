# Custom instructions for the memory-side row unit.
# RISC-V custom-0 opcode (0x0b), R-type: rs1 = destination row address,
# rs2 = source row address, rd = x0 (no register result).
.macro pim_copy dst, src
    .insn r 0x0b, 0, 0, x0, \dst, \src
.endm
.macro pim_and dst, src
    .insn r 0x0b, 1, 0, x0, \dst, \src
.endm
