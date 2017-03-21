#ifndef __mmap_types_h
#define __mmap_types_h
typedef struct _mmap_struct {
    void* ptr_mmapped_file;
    size_t file_size;
    int status;
} mmap_struct;
#endif
