#!/bin/bash

make

for testcase in tests/*.pzc;
do
    echo "=== Testing $testcase ==="
    ./pzc < $testcase
done
