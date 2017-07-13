#ifndef __VEC_H
#define __VEC_H
#include "mmap_types.h"
extern int
chk_field_type(
    const char * const field_type
    );
extern int
vec_nascent(
    VEC_REC_TYPE *ptr_vec
    );
extern VEC_REC_TYPE *
vec_new(
    const char * const field_type,
    uint32_t field_size,
    uint32_t chunk_size
    );
extern int
vec_materialized(
    VEC_REC_TYPE *ptr_vec,
    const char *const file_name,
    bool is_read_only
    );
extern int
vec_check(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_free(
    VEC_REC_TYPE *ptr_vec
    );
extern bool 
file_exists (
    const char * constfilename
    );
#endif
