.default = all

all: pzc.lib

%.llvm : %.c
	clang -m32 -lm -emit-llvm -S -o $@ $<

%.llb : %.llvm
	opt --std-compile-opts -o $@ $<

pzc.lib : libpzcc.llb
	llvm-link $< -o $@
clean:
	rm *.llb
	rm *.llvm
