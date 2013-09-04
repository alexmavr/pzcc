#/bin/bash

ROOT_DIR=/home/afein/Repos/pzcc/

cd $ROOT_DIR
./pzcc -io tests/linking/2.pzc
llvm-link tests/linking/2.pzc.imm lib-code/src/pzc.lib -f | llc -O3 -march=x86 -o tests/linking/2.asm
as --32 tests/linking/2.asm -o tests/linking/2.o
gcc -m32 -lm tests/linking/2.o -o tests/linking/2
tests/linking/2
