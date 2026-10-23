#!/bin/sh
# usage: sw/asm2hex.sh sw/sum.s    ->  writes sw/sum.hex
set -e
name=$(basename "$1" .s)
mkdir -p sim
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o sim/$name.o "$1"
riscv64-unknown-elf-ld -m elf32lriscv -Ttext=0 -o sim/$name.elf sim/$name.o
riscv64-unknown-elf-objcopy -O binary sim/$name.elf sim/$name.bin
od -An -v -tx4 -w4 sim/$name.bin | tr -d ' ' > sw/$name.hex
