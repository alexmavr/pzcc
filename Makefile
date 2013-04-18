.PHONY: all pzc clean
.DEFAULT: all

CC = gcc
CCFLAGS += -Wall 
LDFLAGS +=

OBJ += pzc.lex.o comp_lib.o parser.o
DEPENDS += 

ifndef DEBUG
       DEBUG = y
endif

ifeq ($(DEBUG),y)
	CCFLAGS += -O0
	BSN_DBG += -t
else
	CCFLAGS += -O3
endif

all: pzc clean

pzc: $(OBJ) 
	$(CC) $(LDFLAGS) $(OBJ) -o $@

parser.h: parser.c

parser.c: parser.y
		bison ${BSN_DBG} -v -d -o $@ $<

pzc.lex.o: pzc.lex.c parser.h
	$(CC) $(CCFLAGS) -c -lfl $< -o $@

pzc.lex.c: pzc.lex
	flex -s -o $@ $< 

pzc.lex:;

distclean: clean
	rm -f pzc parser.output

clena celan lcean lcena: clean
clean:
	rm -f $(OBJ) pzc.lex.c a.out parser.c parser.h
