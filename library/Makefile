.PHONY: all clean distclean install uninstall
.DEFAULT: all

all: libpzc.ll clean

%.llvm : %.c
	clang -emit-llvm -S -o $@ $<
%.lli : %.llvm
	opt --std-compile-opts -S -o $@ $<
%.ll : %.lli
	llvm-link -S $< -o $@

distclean: clean
	rm --force libpzc.ll
clean:
	rm --force *.lli *.llvm

install:
	mkdir --parents /usr/lib/pzcc/
	mv libpzc.ll /usr/lib/pzcc/
	ln --interactive --symbolic /usr/lib/pzcc/libpzc.ll /usr/lib/libpzc.ll
uninstall:
	rm --force /usr/lib/pzcc/libpzc.ll
	rmdir --ignore-fail-on-non-empty /usr/lib/pzcc/
	rm --force /usr/lib/libpzc.ll
