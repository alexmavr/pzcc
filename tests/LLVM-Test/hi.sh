cflags=`llvm-config --cflags`
#clinkflags=`llvm-config --libs --cflags --ldflags core analysis native`
clinkflags=`llvm-config --libs --cflags --ldflags core`
echo "CFLAGS is $cflags"
echo "CLINKFLAGS is $clinkflags"
gcc $cflags -c "$1" -o obj.o
g++ obj.o $clinkflags -o hi
