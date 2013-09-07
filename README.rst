==============
Pazcal Compiler v1.0
==============

Package Requirements
============

Runtime System
--------------
* clang
* llvm

Buiding the Compiler
--------------------
* g++
* flex
* bison
* llvm
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
    cd lib-code/src
    make
    sudo make install

The install targets place the compiler executable at /usr/bin and the library at /usr/lib/pzcc/

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

Example Usage
-------------

::
    pzcc -o /path/to/source.pzc

This invocation will create an optimized executable at /path/to/source.pzc.out

::
    pzcc -io /path/to/source.pzc

The one will produce optimized IR at /path/to/source.pzc.imm

::
    pzcc -f --llc-flags="-march=x86_64" /path/to/source.pzc

This one will produce 64-bit x86 assembly at /path/to/source.pzc.asm
