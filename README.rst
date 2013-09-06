==============
Pazcal Compiler v1.0
==============

Requirements
============

Runtime System
--------------
* clang

Buiding the Compiler
--------------------
* g++
* flex
* bison
* llvm

Buiding the Library
--------------------
* clang

Features
========
The target architecture is x86. Different architectures can be chosen for the final assembly dump
with --llc-flags="-march=<arch>" where <arch> is any architecture specified by "llc --version".

* -f, --emit-final            Emit final assembly code in the selected architecture
* -i, --emit-intermediate     Emit LLVM intermediate code
* -o, --optimize              Enable all optimizations
* -l, --llc-flags=LLC_FLAGS   Options to be passed to llc when -f is enabled
* -t, --opt-flags=OPT_FLAGS   Options to be passed to opt when -f is enabled

If neither -f nor -i are specified, the compiler produces an executable 32-bit elf file
