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
#include "_get_file_size.h"

//START_FUNC_DECL
int 
f_munmap(
    MMAP_REC_TYPE *ptr_mmap        
)
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ptr_mmap == NULL ) { go_BYE(-1); }
  if ( ptr_mmap->map_addr == NULL ) { go_BYE(-1); }
  if ( ptr_mmap->map_len == 0 ) { go_BYE(-1); }
  if ( ptr_mmap->file_name == NULL ) { go_BYE(-1); }
  int rc = munmap(ptr_mmap->map_addr, ptr_mmap->map_len);
  if ( ptr_mmap->is_persist != 1 ) { 
    fprintf(stderr, "Deleting %s \n", ptr_mmap->file_name);
    status = remove(ptr_mmap->file_name); cBYE(status);
    int64_t sz = get_file_size(ptr_mmap->file_name);
    if ( sz >= 0 ) { fprintf(stderr, "Delete failed, sz = %llu\n", sz); go_BYE(-1); }
  }
  else {
    fprintf(stderr, "NOT Deleting %s \n", ptr_mmap->file_name);
  }
  if ( rc != 0 ) { go_BYE(-1); }
  free(ptr_mmap);
BYE:
  return status;
}
