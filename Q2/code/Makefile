.DEFAULT_GOAL := all
CC = gcc
CFLAGS = -fPIC -std=gnu99
LFLAGS = -shared
RM = rm -f
SOURCE_FILES = $(wildcard *.c)
#CORESO := $(patsubst %.c,%.so,$(SOURCE_FILES))
OBJECTS := $(patsubst %.c,%.o,$(SOURCE_FILES))
CORE_SO = libvector_map.so libprint.so


#%.so: ./%.c
#	$(CC) -o $@ $< $(CFLAGS)

#%.o: %c
#	$(CC) -c $(CFLAGS) $< -o $@

$(OBJECTS): %.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

libvector_map.so: $(OBJECTS)
	$(CC) -shared -o libvector_mmap.so vector_mmap.o bitops.o

libprint.so: $(OBJECTS)
	$(CC) -shared -o libprint.so print.o

all: $(CORE_SO)
	rm $(OBJECTS)
	echo "done"

test: 
	make clean
	make all
	echo "Now testing c function calls"
	$(CC) driver.c -o driver
	./driver > /dev/null
	$(CC) vector_mmap.c -DTEST -o vec
	./vec
	$(CC) bitops.c -DTEST -o bit
	./bit
	cp test.txt test1.txt
	cp test.txt test2.txt
	echo "Now testing lua bindings"
	luajit testVector.lua
	rm ./*.txt *_nn
clean:
	$(RM) $(CORESO) $(OBJECTS)

