CC = gcc
DBG_FLAGS = -g
DBG_FLAGS = 

OPT_FLAGS = 
OPT_FLAGS = -O4
FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp
LINK_FLAGS = -fPIC -shared -lgomp -lpthread -lm
DEPS = matrix_multiply.h

INCS= -I../inc

all : mm libmm.so

%.o: %.c $(DEPS)
	$(CC) $(INCS) $(FLAGS) -c -o $@ $< -I

libmm.so : matrix_multiply.c 
	$(CC) -c $(INCS) $(FLAGS) $(LNK_FLAGS) matrix_multiply.c -o libmm.so
mm: driver_mm.c matrix_multiply.c
	$(CC) $(INCS) $(FLAGS) -lgomp -lpthread -lm \
	  	driver_mm.c matrix_multiply.c mm_helpers.c -o mm

clean:
	rm -f *.o mm *.so
