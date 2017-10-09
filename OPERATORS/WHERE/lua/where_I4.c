#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>
#include <math.h>

int
where_I4(
      const int32_t * restrict A,
      const uint64_t * restrict B,
      uint64_t nA,
      int32_t *C,
      size_t *nC
      )
{
  int status = 0;
  size_t outSize = 0;
  if ( A == NULL ) { go_BYE(-1); }
  if ( B == NULL ) { go_BYE(-1); }
  if ( nA == 0 ) { go_BYE(-1); }
  
#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < nA; i++ ) {
    C[i] = 0;
  }
  
#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < nA; i++ ) {
    uint64_t widx = i >> 8; // word index
    uint64_t bidx = i & 0xFF; // bit index
    uint64_t inv;
    inv = mcr_get_bit(B[widx], bidx); if ( inv != 0 ) { inv = 1; }
    if ( inv == 1 ) {
      C[outSize++] = A[i];
    }
  }
  *nC = outSize;
BYE:
  return status;
}