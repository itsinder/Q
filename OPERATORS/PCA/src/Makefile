CC = gcc
DBG_FLAGS = 
DBG_FLAGS = -g

OPT_FLAGS = -O4
OPT_FLAGS = 

FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) -std=gnu99 -fPIC -Wall -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic 
# LINK_FLAGS =  -lm -lgomp -llapacke  -llapack -lblas
LINK_FLAGS = -llapacke -llapack -lblas -lm -Wall
DEPS = matrix_multiply.h

INCS= -I../../../UTILS/inc

all: eigen libeigen.so
	test -d ${QQ_BUILD_DIR}
	cp eigenvectors.c ${Q_BUILD_DIR}/src/
	cp eigenvectors.h ${Q_BUILD_DIR}/include/

libeigen.so : eigenvectors.c
	$(CC) -c $(INCS) $(FLAGS) eigenvectors.c -o libeigen.so

eigen: eigenvectors.o test_eigenvectors.o
	$(CC) $(INCS) $(FLAGS)  \
	eigenvectors.o test_eigenvectors.o  -o eigen $(LINK_FLAGS)

.c.o : $(DEPS)
	$(CC) $(INCS) $(FLAGS)  -c -o $@ $< 

clean:
	rm -f *.o 
	rm -f eigen
	rm -f *.so



