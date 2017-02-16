CC = gcc
CFLAGS = -fPIC -shared
RM = rm -f
SOURCE_FILES = $(wildcard *.c)
CORESO := $(patsubst %.c,%.so,$(SOURCE_FILES))
OBJECTS := $(patsubst %.c,%.so,$(SOURCE_FILES))
#CORE_SO = vector_map.so print.so

%.so: ./%.c
	$(CC) -o $@ $< $(CFLAGS)

all: $(CORESO)
	echo "done"

test: 
	$(CC) driver.c
	./a.out > /dev/null
	cp test.txt test1.txt
	cp test.txt test2.txt
	luajit testVector.lua
clean:
	$(RM) $(CORESO)

