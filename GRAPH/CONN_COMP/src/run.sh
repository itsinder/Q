gcc -g $QC_FLAGS proc_uk_graph.c \
  $HOME/WORK/Q/UTILS/src/mmap.c \
  -I$HOME/WORK/Q/UTILS/inc/ \
  -I$HOME/WORK/Q/UTILS/gen_inc/ 

gcc -O4 $QC_FLAGS x.c \
  $HOME/WORK/Q/UTILS/src/mmap.c \
  -I$HOME/WORK/Q/UTILS/inc/ \
  -I$HOME/WORK/Q/UTILS/gen_inc/ 
