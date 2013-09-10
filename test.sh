#/bin/bash

ROOT_DIR=~/Repos/pzcc/

cd $ROOT_DIR
./pzcc -io tests/examples/$1.pzc
llvm-link tests/examples/$1.pzc.imm /usr/lib/libpzc.ll -f | llc -O3 -filetype=obj -march=x86 -o tests/examples/$1.o
clang -m32 tests/examples/$1.o -lm -o tests/examples/$1
tests/examples/$1
