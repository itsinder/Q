CC = gcc
DBG_FLAGS = 
DBG_FLAGS = -g

OPT_FLAGS = -O4
OPT_FLAGS = 

FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) ${QC_FLAGS}
# LINK_FLAGS =  -lm -lgomp -llapacke  -llapack -lblas
LINK_FLAGS = -llapacke -llapack -lblas -lm -Wall -shared

INCS= -I../../../UTILS/inc

all: eigen libeigen.so
	test -d ${QQ_BUILD_DIR}
	cp eigenvectors.c ${Q_BUILD_DIR}/src/
	cp eigenvectors.h ${Q_BUILD_DIR}/include/

libeigen.so : eigenvectors.c
	$(CC) $(INCS) $(FLAGS) ${LINK_FLAGS}  eigenvectors.c -o libeigen.so

eigen: eigenvectors.o test_eigenvectors.o
	$(CC) $(INCS) $(FLAGS)  -shared \
	eigenvectors.o test_eigenvectors.o  -o eigen $(LINK_FLAGS)

.c.o : $(DEPS)
	$(CC) $(INCS) $(FLAGS)  -c -o $@ $< 

clean:
	rm -f *.o 
	rm -f eigen
	rm -f *.so



