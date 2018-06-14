gcc -O4 -I../../../UTILS/inc/ -std=c99 unique_I4.c -o unique_I4.o
gcc -O4 -I../../../UTILS/inc/ -fPIC -std=gnu99 -shared  unique_I4.c -o unique_I4.so

./unique_I4.o

rm unique_I4.o
