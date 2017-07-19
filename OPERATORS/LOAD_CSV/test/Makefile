CC = gcc
DBG_FLAGS = 
DBG_FLAGS = -g

OPT_FLAGS = -O4
OPT_FLAGS = 
FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic
LINK_FLAGS = -fPIC -shared

INCS= -I../inc \
	-I../gen_inc \
	-I../../../UTILS/inc \
	-I../../../UTILS/gen_inc

all : test_num_load_csv

SRCS = ../src/num_load_csv.c \
       test_num_load_csv.c  \
       ../../../UTILS/src/mmap.c \
       ../../../UTILS/src/is_valid_chars_for_num.c \
       ../src/get_cell.c \
       ../gen_src/_txt_to_I1.c \
       ../gen_src/_txt_to_I2.c \
       ../gen_src/_txt_to_I4.c \
       ../gen_src/_txt_to_I8.c \
       ../gen_src/_txt_to_F4.c \
       ../gen_src/_txt_to_F8.c \

%.o: %.c $(DEPS)
	$(CC) $(INCS) $(FLAGS) -c -o $@ $< -I

test_num_load_csv : $(SRCS)
	$(CC) $(SRCS) $(INCS) $(FLAGS) -o test_num_load_csv
	  	

clean:
	rm -f *.o 
	rm -f test_num_load_csv
	rm -f ../*.o
