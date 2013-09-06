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

Installation
============

At the compiler's root directory:
:: 
    make
    sudo make install
    cd lib-code/src
    make
    sudo make install

Features
========

Target Architecture
-------------------
The default target architecture is the runtime system's native architecture. 

A complete list of support architectures can be viewed with llc --version

Different architectures can be chosen for the final assembly dump
with --llc-flags="-march=<arch>" where <arch> is any architecture name on the left column.

Usage
-----

* -f, --emit-final            Emit final assembly code in the selected architecture
* -i, --emit-intermediate     Emit LLVM intermediate code
* -o, --optimize              Enable all optimizations
* -c, --clang-flags=C_FLAGS   Option string to be used with clang when producing an executable
* -l, --llc-flags=LLC_FLAGS   Options to be passed to llc when -f is enabled
* -t, --opt-flags=OPT_FLAGS   Options to be passed to opt when -f is enabled
* -b, --pzclib=PZC_LIB        Pazcal library used on linking phase when the
                              default output option is in effect
    
If neither -f nor -i are specified, the compiler produces an executable elf file
