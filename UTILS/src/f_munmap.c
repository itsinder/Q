//START_INCLUDES
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
#include "mmap_types.h"
#include "q_incs.h"
//STOP_INCLUDES
#include "_f_munmap.h"

//START_FUNC_DECL
int 
f_munmap(
    MMAP_REC_TYPE *ptr_mmap        
)
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ptr_mmap == NULL ) { go_BYE(-1); }
  int rc = munmap(ptr_mmap->map_addr, ptr_mmap->map_len);
  if ( rc != 0 ) { go_BYE(-1); }
  unlink(ptr_mmap->file_name);
  free(ptr_mmap);
BYE:
  return status;
}
