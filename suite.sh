#!/bin/bash

components=$@

make
cp source/pzcc .

for component in $components;
do
    echo ""
    echo "==========  Now testing $component ============"

    for testcase in tests/$component/*.pzc;
    do echo "========== $testcase ============"
        ./pzcc $testcase
    done
done

#make clean
