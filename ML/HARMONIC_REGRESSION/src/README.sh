gcc -g -std=gnu99 ../../../UTILS/src/mmap.c hr.c \
  ../../../AxEqualsBSolver/aux_driver.c \
  -I../../../UTILS/inc \
  -I../../../AxEqualsBSolver/ \
  -o hr -lm 
