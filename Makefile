.PHONY: all pzc clean
.DEFAULT: all

CC = gcc
CFLAGS += -Wall 
LDFLAGS +=

OBJ += pzc.lex.o comp_lib.o parser.o symbol.o general.o error.o
DEPENDS += 

ifndef DEBUG
       DEBUG = y
endif

ifeq ($(DEBUG),y)
	CFLAGS += -O0 -g
	BSN_DBG += -t
else
	CFLAGS += -O3
endif

all: pzc clean

pzc: $(OBJ) 
	$(CC) $(LDFLAGS) $(OBJ) -o $@

general.o: general.c general.h
	$(CC) $(CFLAGS) -c $< -o $@
error.o: error.c error.h
	$(CC) $(CFLAGS) -c $< -o $@
symbol.o: symbol.c symbol.h general.h
	$(CC) $(CFLAGS) -c $< -o $@

parser.h: parser.c 

parser.c: parser.y comp_lib.h
		bison ${BSN_DBG} -v -d -o $@ $<

pzc.lex.o: pzc.lex.c comp_lib.h parser.h symbol.h
	$(CC) $(CFLAGS) -c -lfl $< -o $@

pzc.lex.c: pzc.lex
	flex -s -o $@ $< 
pzc.lex:;

distclean: clean
	rm -f pzc parser.output

clena celan lcean lcena: clean
clean:
	rm -f $(OBJ) pzc.lex.c a.out parser.c parser.h
