gcc -O4 -I../../../UTILS/inc/ -std=c99 qsort2_asc_I4.c -o qsort2_asc_I4.o
gcc -O4 -I../../../UTILS/inc/ -fPIC -std=gnu99 -shared  qsort2_asc_I4.c -o qsort2_asc_I4.so

./qsort2_asc_I4.o

rm qsort2_asc_I4.o
