#/bin/bash

ROOT_DIR=/home/afein/Repos/pzcc/

cd $ROOT_DIR
./pzcc -io tests/linking/$1.pzc
llvm-link tests/linking/$1.pzc.imm lib-code/src/pzc.lib -f | llc -O3 -march=x86 -o tests/linking/$1.asm
as --32 tests/linking/$1.asm -o tests/linking/$1.o
gcc -m32 -lm tests/linking/$1.o -o tests/linking/$1
tests/linking/$1
