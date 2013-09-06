#/bin/bash

ROOT_DIR=~/Repos/pzcc/

cd $ROOT_DIR
./pzcc -io tests/examples/$1.pzc
llvm-link tests/examples/$1.pzc.imm lib-code/src/pzc.lib -f | llc -O3 -march=x86 -o tests/examples/$1.asm
as --32 tests/examples/$1.asm -o tests/examples/$1.o
gcc -m32 -lm tests/examples/$1.o -o tests/examples/$1
tests/examples/$1
