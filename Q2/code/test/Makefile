.DEFAULT_GOAL := all
INC_DIR = ../gen_inc/
CC = gcc
CFLAGS = -fPIC -std=gnu99 -I$(INC_DIR)
LFLAGS = -shared
RM = rm -f
SOURCE_FILES = $(wildcard *.c)
#CORESO := $(patsubst %.c,%.so,$(SOURCE_FILES))
OBJECTS := $(patsubst %.c,%.o,$(SOURCE_FILES))
CORE_SO = ../src/libvector_map.so libprint.so


#%.so: ./%.c
#	$(CC) -o $@ $< $(CFLAGS)

#%.o: %c
#	$(CC) -c $(CFLAGS) $< -o $@

$(OBJECTS): %.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

../src/libvector_map.so: $(OBJECTS)
	cd ../src/
	#make

libprint.so: $(OBJECTS)
	$(CC) -shared -o libprint.so print.o

all: $(CORE_SO)
	rm $(OBJECTS)
	echo "Now testing c function calls"
	$(CC) driver.c -o driver
	./driver > /dev/null
	# $(CC) `pwd`/../src/vector_mmap.c `pwd`/../src/vector_munmap.c -DTEST -I$(INC_DIR) -o vec
	$(CC) ../src/vector_mmap.c ../src/vector_munmap.c -DTEST -I$(INC_DIR) -o vec
	./vec
	$(CC) ../src/bitops.c -DTEST -I$(INC_DIR) -o bit
	./bit
	cp test.txt test1.txt
	cp test.txt test2.txt
	echo "Now testing lua bindings"
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:./"
	luajit testVector.lua
	rm ./*.txt *_nn _* driver bit vec libprint.so
clean:
	$(RM) $(CORESO) $(OBJECTS)

