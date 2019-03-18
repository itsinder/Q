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

clean:
	rm -r -f *.so *.o _*
		
CSRCS := $(wildcard *.c)
COBJS = $(CSRCS:.c=.o)

CFLAGS = $(QC_FLAGS)  
# CFLAGS = $(QC_FLAGS) -DTEST_VS_PYTHON
# CFLAGS = $(QC_FLAGS) -DCOUNT # for counting flops

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

dnn.o : dnn.c ../inc/dnn_types.h ../inc/core_dnn.h
	gcc -c ${CFLAGS} $(INCS) dnn.c -o dnn.o

fstep_a.o : fstep_a.c ../inc/dnn_types.h ../inc/fstep_a.h
	gcc -c ${CFLAGS} $(INCS) fstep_a.c -o fstep_a.o

bstep.o : bstep.c ../inc/dnn_types.h ../inc/bstep.h
	gcc -c ${CFLAGS} $(INCS) bstep.c -o bstep.o

act_fns.o : act_fns.c ../inc/dnn_types.h ../inc/act_fns.h
	gcc -c ${CFLAGS} $(INCS) act_fns.c -o act_fns.o

update_W_b.o : update_W_b.c ../inc/dnn_types.h ../inc/update_W_b.h
	gcc -c ${CFLAGS} $(INCS) update_W_b.c -o update_W_b.o

core_dnn.o : core_dnn.c ../inc/dnn_types.h ../inc/core_dnn.h
	gcc -c ${CFLAGS} $(INCS) core_dnn.c -o core_dnn.o

libdnn.so: core_dnn.o dnn.o fstep_a.o bstep.o act_fns.o update_W_b.o
	gcc ${CFLAGS} $(INCS) \
	core_dnn.o \
	dnn.o \
	update_W_b.o \
	act_fns.o \
	fstep_a.o \
	bstep.o \
	-shared -o libdnn.so
