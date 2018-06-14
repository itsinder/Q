gcc -O4 -std=c99 unique.c -o unique.o
gcc -O4 -fPIC -std=gnu99 -shared  unique.c -o unique.so

./unique.o

rm unique.o
