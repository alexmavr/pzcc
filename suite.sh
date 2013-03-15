#!/bin/bash

components=('lexer')

make

for component in $components;
do
    echo ""
    echo "==========  Now testing $component ============"

    for testcase in tests/$component/*.pzc;
    do echo "========== $testcase ============"
        ./pzc < $testcase
    done
done

make clean
