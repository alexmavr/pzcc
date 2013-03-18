.PHONY: all clean
.DEFAULT: all

CC = gcc
CCFLAGS += -Wall -O0

OBJ += pzc.lex.o comp_lib.o
DEPENDS += 

pzc: $(OBJ) 
	$(CC) $(LDFLAGS) $(OBJ) -o $@

pzc.lex.o: pzc.lex.c
	$(CC) $(CCFLAGS) -c -lfl $< -o $@

pzc.lex.c: pzc.lex
	flex -s -o $@ $< 

pzc.lex:;

clena celan lcean lcena: clean
clean:
	rm -f $(OBJ) pzc.lex.c pzc a.out
