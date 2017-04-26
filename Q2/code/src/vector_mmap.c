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
#include <time.h>

#define MAX_LEN_DIR_NAME 1000
#include "mmap_struct.h"
#include "_vector_mmap.h"

//START_FUNC_DECL
mmap_struct*
vector_mmap(
   const char* file_name,
   bool is_write
)
//STOP_FUNC_DECL
{
   mmap_struct *map = malloc(sizeof(mmap_struct));
   map->status = -1;
   int status = 0;
   int fd;
   struct stat filestat;
   size_t len;
   
   if (is_write == true) {
      fd = open(file_name, O_RDWR);
   } else {
      fd = open(file_name, O_RDONLY);
   }
   if (fd < 0) {
      char cwd[MAX_LEN_DIR_NAME + 1];
      if (getcwd(cwd, MAX_LEN_DIR_NAME) != NULL) {
      fprintf(stderr, "Could not open file [%s] \n", file_name);
      fprintf(stderr, "Currently in dir    [%s] \n", cwd);
      }
      return map;
   }
   status = fstat(fd, &filestat);
   if (status < 0){
         return map;
   } 
   len = filestat.st_size;
   /* It is okay for file size to be 0 */
   if (len == 0) {
      map->ptr_mmapped_file = NULL;
      map->ptr_file_size = 0;
   } else {
      if (is_write == true) {
         map->ptr_mmapped_file = (void*)mmap(NULL, (size_t) len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
      } else {
         map->ptr_mmapped_file = (void*)mmap(NULL, (size_t) len, PROT_READ, MAP_SHARED, fd, 0);
      }
      close(fd);
      map->ptr_file_size = filestat.st_size;
   }
   map->status = 0;
   return map;
}

#ifdef TEST
int main() {
    const char* f_name = "test.txt";
    mmap_struct* s;
    s = vector_mmap(f_name, false);
    printf("%d\n", s->status);
    printf("%s\n", s->ptr_mmapped_file);
    int status = vector_munmap(s);
    printf("%d\n",status );
    char time_buffer[26];
	time_t timer;
    struct tm* tm_info;
    time(&timer);
    tm_info = localtime(&timer);
    strftime(time_buffer, 26, "%d/%m/%y %H:%M", tm_info);
	printf("__Q_TEST__%s; %s; Vector; testing vector_munmap; %d; %s\n",
		 time_buffer, __FILE__, status, status==0 ? "SUCCESS": "FAIL");
}
#endif
