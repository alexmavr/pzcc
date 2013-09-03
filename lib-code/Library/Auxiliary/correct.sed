s/DWORD/dword/g
s/WORD/word/g
s/TBYTE/tbyte/g
s/BYTE/byte/g
s/PTR/ptr/g

s/\[\([0-9]\+\)+\([^]]\+\)\]/[\2+\1]/g
s/\[-\([0-9]\+\)+\([^]]\+\)\]/[\2-\1]/g

s/(offset \([^)]\+\))/OFFSET \1/g

s/dword/word/g

s/eax/ax/g
s/ebx/bx/g
s/ecx/cx/g
s/edx/dx/g
s/esp/sp/g
s/ebp/bp/g
s/esi/si/g
s/edi/di/g

s/,\t/, /g
s/^\([^:;]\+\)$/\t\1/
