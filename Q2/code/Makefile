.DEFAULT_GOAL := all
CC = gcc
CFLAGS = -fPIC
LFLAGS = -shared
RM = rm -f
SOURCE_FILES = $(wildcard *.c)
#CORESO := $(patsubst %.c,%.so,$(SOURCE_FILES))
OBJECTS := $(patsubst %.c,%.o,$(SOURCE_FILES))
CORE_SO = vector_map.so print.so


#%.so: ./%.c
#	$(CC) -o $@ $< $(CFLAGS)

#%.o: %c
#	$(CC) -c $(CFLAGS) $< -o $@

$(OBJECTS): %.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

vector_map.so: $(OBJECTS)
	$(CC) -shared -o vector_mmap.so vector_mmap.o bitops.o

print.so: $(OBJECTS)
	$(CC) -shared -o print.so print.o

all: $(CORE_SO)
	echo "done"

test: 
	$(CC) driver.c -o driver
	./driver > /dev/null
	$(CC) vector_mmap.c -DTEST -o vec
	./vec
	$(CC) bitops.c -DTEST -o bit
	./bit
	cp test.txt test1.txt
	cp test.txt test2.txt
	luajit testVector.lua
	echo "Now testing c function calls"
clean:
	$(RM) $(CORESO) $(OBJECTS)

