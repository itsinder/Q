#ifndef __mmap_struct
#define __mmap_struct
typedef struct {
    void* ptr_mmapped_file;
    size_t ptr_file_size;
    int status;
} mmap_struct;
#endif
