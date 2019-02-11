# Why are we depending on print and load csv?
INCS= -I../inc/ \
	-I../../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc/ \
	-I../../OPERATORS/LOAD_CSV/gen_inc/ \
	-I../../OPERATORS/PRINT/gen_inc/ \
	-I/usr/include/lua5.1/

CC=clang
CC=gcc

all: libdnn.so 
	cp libdnn.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
		
CSRCS := $(wildcard *.c)
COBJS = $(CSRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

dnn.o : dnn.c ../inc/dnn_types.h ../inc/core_dnn.h
	gcc -c ${QC_FLAGS} $(INCS) dnn.c -o dnn.o

core_dnn.o : core_dnn.c ../inc/dnn_types.h ../inc/core_dnn.h
	gcc -c ${QC_FLAGS} $(INCS) core_dnn.c -o core_dnn.o

libdnn.so: *.o
	gcc ${QC_FLAGS} $(INCS) \
	core_dnn.o \
	dnn.o \
	-shared -o libdnn.so
