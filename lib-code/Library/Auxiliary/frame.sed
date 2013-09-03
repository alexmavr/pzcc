s/^.*tbyte ptr \[bp\([^]]\+\)\].*$/FRAME:\t\1\t10 bytes\t\1/
s/^.*word ptr \[bp\([^]]\+\)\].*$/FRAME:\t\1\t 2 bytes\t\1/
s/^.*byte ptr \[bp\([^]]\+\)\].*$/FRAME:\t\1\t 1 byte\t\1/
s/^.*\[bp\([^]]\+\)\].*$/FRAME:\t\1\tunknown !!!/
