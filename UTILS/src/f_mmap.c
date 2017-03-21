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
//STOP_INCLUDES
#include "_f_mmap.h"
//START_FUNC_DECL
mmap_struct*
f_mmap(
   const char * const file_name,
   bool is_write
)
//STOP_FUNC_DECL
{
  mmap_struct *map = malloc(sizeof(mmap_struct));
  if ( map == NULL ) { return NULL; }
  map->status = -1;
  map->ptr_mmapped_file = NULL;
  map->file_size = 0;

  int status = 0;
  int fd, flags;
  struct stat filestat;
  size_t len;

  //---------------------
  if ( is_write ) {
    fd = open(file_name, O_RDWR);
  } 
  else {
    fd = open(file_name, O_RDONLY);
  }
  if ( fd < 0 ) { free(map); return NULL; }
  status = fstat(fd, &filestat);
  if (status < 0) { free(map); return NULL; }
  len = filestat.st_size;
  if ( len == 0 ) {  free(map); return NULL; }
  if (is_write == true) {
    flags = PROT_READ | PROT_WRITE;
  }
  else {
    flags = PROT_READ;
  }
  map->ptr_mmapped_file = 
    (void*)mmap(NULL, (size_t) len,  flags, MAP_SHARED, fd, 0);
  close(fd);
  map->file_size = filestat.st_size;
  map->status = 0;
  return map;
}
