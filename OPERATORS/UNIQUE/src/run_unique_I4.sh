gcc -O4 -I../../../UTILS/inc/ -std=c99 unique_func_I4.c -o unique_func_I4.o
gcc -O4 -I../../../UTILS/inc/ -fPIC -std=gnu99 -shared  unique_func_I4.c -o unique_func_I4.so

./unique_func_I4.o

rm unique_func_I4.o
