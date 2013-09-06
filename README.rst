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

Target Architecture
-------------------
The default target architecture is the runtime system's native architecture. 

The following architectures are supported as of LLVM version 3.2:
arm      -  ARM
cpp      -  C++ backend
hexagon  -  Hexagon
mblaze   -  MBlaze
mips     -  Mips
mips64   -  Mips64 [experimental]
mips64el -  Mips64el [experimental]
mipsel   -  Mipsel
msp430   -  MSP430 [experimental]
nvptx    -  NVIDIA PTX 32-bit
nvptx64  -  NVIDIA PTX 64-bit
ppc32    -  PowerPC 32
ppc64    -  PowerPC 64
r600     -  AMD GPUs HD2XXX-HD6XXX
sparc    -  Sparc
sparcv9  -  Sparc V9
thumb    -  Thumb
x86      -  32-bit X86: Pentium-Pro and above
x86-64   -  64-bit X86: EM64T and AMD64


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
    
If neither -f nor -i are specified, the compiler produces an executable 32-bit elf file
