
CC = gcc
DBG_FLAGS = 
DBG_FLAGS = -g

OPT_FLAGS = -O4
OPT_FLAGS = 

FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) -std=gnu99 -fPIC -Wall -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic
LINK_FLAGS =  -lm -lgomp 

INCS= -I../../../UTILS/inc -I../inc

all: vc libvc.so
	test -d ${QQ_BUILD_DIR}
	cp var_covar.c ${Q_BUILD_DIR}/src/
	cp var_covar.h ${Q_BUILD_DIR}/include/
# The LINK_FLAGS need to go at the end, otherwise the make will not work as
# expected
libvc.so : var_covar.c
	$(CC) -shared $(INCS) $(FLAGS) $(LINK_FLAGS) var_covar.c -o libvc.so 

vc: var_covar.o test_var_covar.o
	$(CC) $(INCS) $(FLAGS) $(LINK_FLAGS) \
	var_covar.o test_var_covar.o -o vc

.c.o : $(DEPS)
	$(CC) $(INCS) $(FLAGS)  -c -o $@ $< 

clean:
	rm -f *.o 
	rm -f vc
	rm -f *.so



