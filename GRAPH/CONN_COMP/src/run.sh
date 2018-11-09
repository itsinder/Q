#/bin/bash
set -e
gcc -O4 -std=gnu99 -Wall -fopenmp \
  degree_histo.c \
  ../../../UTILS/src/mmap.c  \
  ../../../UTILS/src/rdtsc.c  \
  -I../../../UTILS/inc/  \
  -I../../../UTILS/gen_inc/ \
  -lpthread -lgomp
echo "Built"
maxid=124900000
./a.out ../data/efile _node_id _degree $maxid
echo "Done"
