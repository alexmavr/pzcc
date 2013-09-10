====================
Pazcal Compiler v1.0
====================

Package Requirements
====================

Runtime System
--------------
* clang
* LLVM >= 3.2

Buiding the Compiler
--------------------
* flex
* bison
* gcc
* g++
* LLVM >= 3.2
* libgc-dev (debian) or gc (arch linux)

Buiding the Library
--------------------
* clang

Installation
============

At the compiler's root directory:
:: 
    make
    sudo make install
    make -C lib-code/src
    sudo make -C lib-code/src install

The install targets place the compiler executable at /usr/bin/ and the library at /usr/lib/pzcc/ .

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
    
If neither -f nor -i are specified, the compiler produces an executable ELF file.

IMPORTANT: Please note that unoptimized programs have troubles handling overflows which may cause segmentation faults at runtime.

Example Usage
-------------

:code: pzcc -o path/to/source.pzc

This invocation will create an optimized executable at path/to/source.pzc.out

:code: pzcc -io path/to/source.pzc

The one will produce optimized IR at path/to/source.pzc.imm

:code: pzcc -f --llc-flags="-march=x86_64" path/to/source.pzc

This one will produce 64-bit x86 assembly at path/to/source.pzc.asm
