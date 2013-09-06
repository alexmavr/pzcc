#/bin/bash

ROOT_DIR=~/Repos/pzcc/

cd $ROOT_DIR
./pzcc -io tests/examples/$1.pzc
llvm-link tests/examples/$1.pzc.imm /usr/lib/pzcc/pzc.lib -f | llc -O3 -filetype=obj -march=x86 -o tests/examples/$1.o
clang -m32 -lm tests/examples/$1.o -o tests/examples/$1
tests/examples/$1
