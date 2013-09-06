.default = all

all: pzc.lib clean

%.llvm : %.c
	clang -m32 -lm -emit-llvm -S -o $@ $<

%.llb : %.llvm
	opt --std-compile-opts -o $@ $<

pzc.lib : libpzcc.llb
	llvm-link $< -o $@

install:
	mkdir /usr/lib/pzcc/
	cp pzc.lib /usr/lib/pzcc/

clean:
	rm *.llb
	rm *.llvm
