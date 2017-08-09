#ifndef __VEC_H
#define __VEC_H
#include "mmap_types.h"
extern int
chk_field_type(
    const char * const field_type,
    uint32_t field_size
    );
extern int
vec_meta(
    VEC_REC_TYPE *ptr_vec,
    char *opbuf
    );
extern int
vec_nascent(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_size,
    uint32_t chunk_size,
    bool  is_memo
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
extern int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    uint64_t idx, 
    uint32_t len
    );
extern int
vec_eov(
    VEC_REC_TYPE *ptr_vec,
    bool is_read_only
    );
extern int
vec_persist(
    VEC_REC_TYPE *ptr_vec,
    bool is_persist
    );
extern int
vec_get(
    VEC_REC_TYPE *ptr_vec,
    int64_t idx, 
    uint32_t len
    );
extern int
is_eq_I4(
    void *X,
    int val
    );
extern int
vec_memo(
    VEC_REC_TYPE *ptr_vec,
    bool is_memo
    );
extern int
vec_add(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    uint32_t len
    );
extern int
vec_add_B1(
    VEC_REC_TYPE *ptr_vec,
    char * addr, 
    uint32_t len
    );
extern int flush_buffer_B1(
    VEC_REC_TYPE *ptr_vec
    );
extern int 
flush_buffer(
          VEC_REC_TYPE *ptr_vec
          );
#endif
