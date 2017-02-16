/* START HDR FILES  */
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

#define MAX_LEN_DIR_NAME 1000
// START FUNC DECL

typedef struct {
    void* ptr_mmapped_file;
    size_t ptr_file_size;
    int status;
} mmap_struct;

mmap_struct*
vector_mmap(
   const char* file_name,
   bool is_write
)
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

int vector_munmap(
    mmap_struct* map        
)
{
    int rc = munmap(map->ptr_mmapped_file, map->ptr_file_size);
    if (rc != 0 )
        return -1;
    free(map);
    return 0;
}

FILE* open_file(const char* path) {
    FILE* fp = fopen(path, "ab"); // TODO write in portable version
    return fp;
}
void flush_file(FILE* fp) {
    fflush(fp);
}


int main() {
    const char* f_name = "test.txt";
    mmap_struct* s;
    s = vector_mmap(f_name, false);
    printf("%d\n", s->status);
    printf("%s\n", s->ptr_mmapped_file);
    printf("%d\n", vector_munmap(s));

}
