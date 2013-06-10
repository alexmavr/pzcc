.PHONY: all pzcc clean
.DEFAULT: all

CC = gcc
LD = g++
LLVMFLAGS = $(shell llvm-config --cflags)
CFLAGS += -Wall $(LLVMFLAGS)
LDFLAGS +=
LLVM_LINK_FLAGS=$(shell llvm-config --libs --cflags --ldflags core analysis native)
OBJ += pzc.lex.o semantic.o parser.o symbol.o general.o error.o ir.o
DEPENDS += 

ifndef DEBUG
       DEBUG = n
endif

ifeq ($(DEBUG),y)
	CFLAGS += -O0 -g
	BSN_DBG += -t
else
	CFLAGS += -O3
endif

all: pzcc clean

pzcc: $(OBJ) 
	$(LD) $(OBJ) $(LDFLAGS) $(LLVM_LINK_FLAGS) -o $@

general.o: general.c general.h
	$(CC) $(CFLAGS) -c $< -o $@
semantic.o: semantic.c semantic.h
	$(CC) $(CFLAGS) -c $< -o $@
error.o: error.c error.h
	$(CC) $(CFLAGS) -c $< -o $@
symbol.o: symbol.c symbol.h general.h
	$(CC) $(CFLAGS) -c $< -o $@
parser.o: parser.c parser.h 
	$(CC) $(CFLAGS) -c $< -o $@

parser.h: parser.c 

parser.c: parser.y semantic.h
		bison ${BSN_DBG} -v -d -o $@ $<

pzc.lex.o: pzc.lex.c semantic.h parser.h symbol.h
	$(CC) $(CFLAGS) -c -lfl $< -o $@

pzc.lex.c: pzc.lex
	flex -s -o $@ $< 
pzc.lex:;

distclean: clean
	rm -f pzcc parser.output

clena celan lcean lcena: clean
clean:
	rm -f $(OBJ) pzc.lex.c a.out parser.c parser.h
