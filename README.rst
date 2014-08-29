====================
Pazcal Compiler v1.0
====================

Static compiler for the Pazcal Language (Papaspyrou-Zachos C-like Algorithmic Language)

**Pazcal** is an educational subset of the C programming language.
It is intended for teaching 
[Introduction to Computer Programming]
(http://courses.softlab.ntua.gr/progintro/)
to first-year students of the
[School of Electrical and Computer Engineering](http://www.ece.ntua.gr/)
at the
[National Technical University of Athens](http://www.ntua.gr/).


Requirements
====================

* flex
* bison
* gcc
* g++
* LLVM >= 3.2
* libgc-dev (debian linux) or gc (arch linux)

Installation
============

At the compiler's root directory:
:: 
    make
    sudo make install

The compiler executable is placed at /usr/bin/ and the library at /usr/lib/pzcc/ .
Internal compiler messages can be enabled with the following invocation of make:
:: 
   make DEBUG=y

Features
========

Target Architecture
-------------------
The default target architecture is the native architecture of the runtime system. 

A complete list of support architectures can be viewed with llc --version

Different architectures can be chosen for the final assembly dump
with --llc-flags="-march=<arch>" where <arch> is any architecture name on the left column.

Usage
-----

* -v, --verbose               Verbose report of execlp calls to llvm and clang executables
* -f, --emit-final            Emit final assembly code for the selected architecture
* -i, --emit-intermediate     Emit LLVM intermediate code
* -O, --optimize              Enable all optimizations
* -c, --clang-flags=C_FLAGS   Option string to be used with clang when producing an executable
* -l, --llc-flags=LLC_FLAGS   Options to be passed to llc when -f is enabled
* -t, --opt-flags=OPT_FLAGS   Options to be passed to opt when -f is enabled
* -b, --pzclib=PZC_LIB        Pazcal library used on linking phase when the
                              default output option is in effect
    
If neither -f nor -i are specified, the compiler produces an executable ELF file.

IMPORTANT: Please note that unoptimized LLVM-IR programs have troubles handling overflows which may lead to segmentation faults.

Example Usage
-------------

:code: pzcc -o path/to/source.pzc

An optimized executable is created at path/to/source.pzc.out

:code: pzcc -io path/to/source.pzc

An optimized LLVM-IR is created at path/to/source.pzc.imm

:code: pzcc -f --llc-flags="-march=x86_64" path/to/source.pzc

An unoptimized 64-bit x86 assembly file is created at path/to/source.pzc.asm
