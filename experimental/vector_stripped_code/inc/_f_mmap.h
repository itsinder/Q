
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
#include <ctype.h>
#include <errno.h>
#include <malloc.h>
#include "q_incs.h"
#include "mmap_types.h"
extern MMAP_REC_TYPE *
f_mmap(
   char * const file_name,
   bool is_write
);
