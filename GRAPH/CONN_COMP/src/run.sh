gcc -g $QC_FLAGS proc_uk_graph.c \
  $HOME/WORK/Q/UTILS/src/mmap.c \
  -I$HOME/WORK/Q/UTILS/inc/ \
  -I$HOME/WORK/Q/UTILS/gen_inc/

gcc -g $QC_FLAGS conn_comp.c \
  $HOME/WORK/Q/UTILS/src/mmap.c \
  -I$HOME/WORK/Q/UTILS/inc/ \
  -I$HOME/WORK/Q/UTILS/gen_inc/ -o conn_comp

datafile=$HOME/ukgraph-5
test -f $datafile
./a.out $datafile out y
echo "Successfully completed $0 in $PWD"
