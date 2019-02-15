// mm =  Memory Manager
#include "q_incs.h"
#include "mm.h"

int
mm(
    uint64_t n,
    bool is_incr,
    bool is_vec,
    uint64_t *ptr_vec_sz,
    uint64_t *ptr_cmem_sz
    )
{
  int status = 0;
  static uint64_t vec_sz_malloc;           // number of bytes allocated
  static uint64_t cmem_sz_malloc;           // number of bytes allocated
  if ( n == 0 ) { go_BYE(-1); } // Added this line experimentally
  if ( n > 0 ) {
    if ( is_incr ) { 
      if ( is_vec ) { 
        vec_sz_malloc += n;
      }
      else {
        cmem_sz_malloc += n;
      }
    }
    else {
      if ( is_vec ) { 
        if ( vec_sz_malloc < n ) { go_BYE(-1); }
        vec_sz_malloc -= n;
      }
      else {
        if ( cmem_sz_malloc < n ) { go_BYE(-1); }
        cmem_sz_malloc -= n;
      }
    }
  }
  *ptr_vec_sz = vec_sz_malloc;
  *ptr_cmem_sz = cmem_sz_malloc;
BYE:
  return status;
}
