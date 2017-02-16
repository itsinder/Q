gcc -g -std=gnu99 ../../../UTILS/src/mmap.c hr.c \
  ../../../AxEqualsBSolver/aux_driver.c \
  ../../../AxEqualsBSolver/positive_solver.c \
  -I../../../UTILS/inc \
  -I../../../AxEqualsBSolver/ \
  -o hr -lm 

./hr ../data/harm_reg.csv _out.csv
