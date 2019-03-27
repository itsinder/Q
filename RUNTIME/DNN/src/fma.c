#include <immintrin.h>

#include "fma.h"

#define REG_WIDTH_IN_BITS 256

#ifdef AVX
int a_times_sb_plus_c(
    float *A,
    float sB,
    float *C,
    float *D,
    int32_t nI
    )
{
  int status = 0;

  int bits_per_byte = 8;
  int stride = REG_WIDTH_IN_BITS / (bits_per_byte * sizeof(float));
  int nI_rem = ( nI % stride );

  // loop with fma
  __m256 b = _mm256_setr_ps(sB, sB, sB, sB, sB, sB, sB, sB);
  for ( int i = 0; i < (nI-nI_rem); i += stride ) {
    __m256 a = _mm256_load_ps(A+i);
    __m256 c = _mm256_load_ps(C+i);
    __m256 d = _mm256_fmadd_ps(a, b, c);
    _mm256_store_ps(D+i, d);
#ifdef COUNT
    num_f_flops += 2*stride;
#endif
  }

  // loop without fma
  for ( int i = (nI-nI_rem); i < nI; i++ ) {
    D[i] = C[i] + (A[i] * sB);
#ifdef COUNT
    num_f_flops += 2;
#endif
  }
BYE:
  return status;
}
#endif
//===========================================================================
