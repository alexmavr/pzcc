.PHONY: all clean distclean
.DEFAULT: all

CC = gcc
CCFLAGS += -Wall -O0

OBJ += lexer.o
DEPENDS += 

pzc: $(OBJ) 
	$(CC) $(LDFLAGS) $(OBJ) -o $@

lexer.o: lexer.c
	$(CC) $(CCFLAGS) -c -lfl $< -o $@

lexer.c: pzc.lex
	flex -o $@ $< 

clean:
	rm $(OBJ) lexer.c pzc
