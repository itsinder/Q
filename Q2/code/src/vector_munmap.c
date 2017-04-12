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
#include "mmap_struct.h"
#include "_vector_munmap.h"
//START_FUNC_DECL
int vector_munmap(
    mmap_struct* map        
)
//STOP_FUNC_DECL
{
    int rc = munmap(map->ptr_mmapped_file, map->ptr_file_size);
    if (rc != 0 )
        return -1;
    free(map);
    return 0;
}

