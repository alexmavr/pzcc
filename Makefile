.PHONY: all pzc clean
.DEFAULT: all

CC = gcc
CCFLAGS += -Wall -O0

OBJ += pzc.lex.o comp_lib.o parser.o
DEPENDS += 

all: pzc clean

pzc: $(OBJ) 
	$(CC) $(LDFLAGS) $(OBJ) -o $@

parser.c parser.h: parser.y
		bison -v -d -o $@ $<

pzc.lex.o: pzc.lex.c parser.h
	$(CC) $(CCFLAGS) -c -lfl $< -o $@

pzc.lex.c: pzc.lex
	flex -s -o $@ $< 

pzc.lex:;



distclean: clean
	rm -f pzc

clena celan lcean lcena: clean
clean:
	rm -f $(OBJ) pzc.lex.c a.out parser.output parser.c parser.h
