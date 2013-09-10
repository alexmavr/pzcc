MAIN_TARGET = pzcc

.PHONY: all clean distclean install uninstall
.DEFAULT: $(MAIN_TARGET)

# Flags and tools.
# @CFLAGS: On Ubuntu system with multiple llvm versions, it was necessary to append '-I"/usr/include/llvm-c-3.2" -I"/usr/include/llvm-3.2"'.
# @LLVM_LINK_FLAGS: When run as previous, it throws "undefined reference to dladdr" during linking. That is because -ldl must appear before -lLLVMSupport.
CC = gcc
LD = g++
LLVMFLAGS = $(shell llvm-config --cflags)
CFLAGS += -Wall $(LLVMFLAGS)
LDFLAGS += -lgc -DREDIRECT_MALLOC=GC_malloc
LLVM_LINK_FLAGS=$(shell llvm-config --libs core analysis native ; llvm-config --cflags --ldflags)

OBJ += pzc.lex.o semantic.o parser.o symbol.o general.o error.o ir.o termopts.o

ifndef DEBUG
       DEBUG = n
endif
ifeq ($(DEBUG),y)
	CFLAGS += -O0 -g
	BSN_DBG += -t
else
	CFLAGS += -O3
endif

# Main target.
$(MAIN_TARGET): $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) $(LLVM_LINK_FLAGS) -o $@

all: $(MAIN_TARGET) clean

# Object dependencies.
pzc.lex.o: pzc.lex.c semantic.h parser.h symbol.h
	$(CC) $(CFLAGS) -c -lfl $< -o $@
termopts.o: termopts.c termopts.h
	$(CC) $(CFLAGS) -c $< -o $@
general.o: general.c general.h
	$(CC) $(CFLAGS) -c $< -o $@
semantic.o: semantic.c semantic.h
	$(CC) $(CFLAGS) -c $< -o $@
error.o: error.c error.h
	$(CC) $(CFLAGS) -c $< -o $@
symbol.o: symbol.c symbol.h general.h
	$(CC) $(CFLAGS) -c $< -o $@
ir.o: ir.c ir.h
	$(CC) $(CFLAGS) -c $< -o $@
parser.o: parser.c parser.h 
	$(CC) $(CFLAGS) -c $< -o $@

# Source dependencies.
# @parser.c: circular dependency parser.c<-semantic.h. Just removed parser.c<-semantic.h, but kept semantic.h<-parser.h.
pzc.lex:;
pzc.lex.c: pzc.lex
	flex -s -o $@ $<
parser.h: parser.c
parser.c: parser.y pzc.lex.c
	bison ${BSN_DBG} -v -d -o $@ $<
general.c: semantic.h error.h general.h ir.h termopts.h
error.c: error.h general.h
symbol.c: semantic.h symbol.h general.h error.h
termopts.c: general.h error.h termopts.h
ir.c: ir.h error.h
ir.h: symbol.h general.h
semantic.c: semantic.h parser.h general.h error.h ir.h
semantic.h: symbol.h parser.h

# Clean rules.
distclean: clean
	rm --force pzcc
clena celan lcean lcena: clean
clean:
	rm --force $(OBJ) pzc.lex.c a.out parser.c parser.h tests/*/*.imm tests/*/*.asm tests/*/*.out parser.output

# Install rules.
install:
	cp --interactive pzcc /usr/bin
uninstall:
	rm --force /usr/bin/pzcc
