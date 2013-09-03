MV ?= move
RM = del
.default = all

all: pzc.lib

%.llvm : %.c
	clang -m32 -emit-llvm -S -o $@ $<

%.llb : %.llvm
	opt --std-compile-opts -o $@ $<

pzc.lib : formatInteger.llb parseInteger.llb writeInteger.llb
	llvm-link $< -o $@

%.asm1 : %.s
	Tools\att2intl -t $<
	$(MV) $*.asm $@
	sed -f correct.sed $@ > $@.correct
	$(MV) $@.correct $@

%.frame : %.asm1
	sed -f frame.sed $< \
	| grep "^FRAME:" | sort +1 -gr | uniq \
	> $@

%.frame.sed : %.frame
	sed "s|^FRAME:[ \t]\+\([0-9+\-]\+\).*[ \t]\([0-9+\-]\+\)$$|s/\\[bp\1\\]/[NEW\2]/g|" $< > $@

%.asm2 : %.asm1 %.frame.sed	
	sed -f $*.frame.sed $< > $@

%.asm : %.asm2
	sed "s|\[NEW|[bp|g" $< \
	| sed "s|;.*$$||" \
	| sed "s|^[ \t]\+\([^ \t]\+\)|               \1\t|" \
	> $@
	
clean : %.asm
	$(RM) $*.asm1
	$(RM) $*.frame.sed
	$(RM) $*.asm2
