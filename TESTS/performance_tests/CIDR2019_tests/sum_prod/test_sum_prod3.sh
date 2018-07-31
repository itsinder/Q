gcc -O4 $QC_FLAGS $Q_SRC_ROOT/TESTS/performance_tests/CIDR2019_tests/sum_prod/test_sum_prod3.c \
  $Q_SRC_ROOT/ML/LOGREG/src/vanilla_sum_prod3.c \
  $Q_SRC_ROOT/ML/LOGREG/src/sum_prod3.c \
  $Q_SRC_ROOT/UTILS/src/rdtsc.c \
  -I$Q_SRC_ROOT/ML/LOGREG/inc/ \
  -I$Q_SRC_ROOT/UTILS/inc/ \
  -I$Q_SRC_ROOT/UTILS/gen_inc/ -lpthread -lgomp
  
./a.out
rm -f ./a.out
