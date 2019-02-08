# Why are we depending on print and load csv?
INCS= -I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc \
	-I../../OPERATORS/LOAD_CSV/gen_inc/ \
	-I../../OPERATORS/PRINT/gen_inc/ \
	-I/usr/include/lua5.1/

all: libdnn.so 
	cp libdnn.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
		
libdnn.so: 
	gcc ${QC_FLAGS} $(INCS) \
	dnn.c \
	core_dnn.c \
	-shared -o libdnn.so
