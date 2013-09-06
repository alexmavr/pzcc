.PHONY: all clean distclean
.DEFAULT: all

all: libpzc.ll clean

%.llvm : %.c
	clang -emit-llvm -S -o $@ $<

%.lli : %.llvm
	opt --std-compile-opts -S -o $@ $<

libpzc.ll : libpzc.lli
	llvm-link -S $< -o $@

install:
	mkdir -p /usr/lib/pzcc/
	mv libpzc.ll /usr/lib/pzcc/
	ln -s /usr/lib/pzcc/libpzc.ll /usr/lib/libpzc.ll

distclean:
	rm libpzc.ll
	rm /usr/lib/pzcc/libpzc.ll
	rm -d /usr/lib/pzcc/
	rm /usr/lib/libpzc.ll

clean:
	rm *.lli
	rm *.llvm
