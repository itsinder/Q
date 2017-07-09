CC = gcc
DBG_FLAGS = 
DBG_FLAGS = -g

OPT_FLAGS = -O4
OPT_FLAGS = 

FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) -std=gnu99 -fPIC -Wall -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic 
LINK_FLAGS =  -lm -lgomp -llapacke  -llapack
DEPS = matrix_multiply.h

INCS= -I../../../UTILS/inc

t: eigenvectors.o test_eigenvectors.o
	$(CC) $(INCS) $(FLAGS) \
	/usr/lib/liblapack.a \
	/usr/lib/liblapacke.a \
	eigenvectors.o test_eigenvectors.o  -o t

.c.o : $(DEPS)
	$(CC) $(INCS) $(FLAGS) -c -o $@ $< 

clean:
	rm -f *.o 
	rm -f t 



