#include "rand_B1.h"

static inline uint64_t RDTSC()
{
  unsigned int hi, lo;
    __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
      return ((uint64_t)hi << 32) | lo;
}

//START_FUNC_DECL
int
rand_B1(
  uint64_t *X,
  uint64_t nX,
  RAND_B1_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;
  static uint64_t l_sum;

  uint64_t seed = ptr_in->seed;
  double p = ptr_in->probability;
  if ( ( p < 0 ) || ( p > 1 ) ) { go_BYE(-1); }
  if ( idx == 0 ) { //seed has not yet been set
    l_sum = 0;
    if ( seed == 0 ) {
     seed = RDTSC();
    }
    srand48(seed);
  }
// #pragma omp parallel for
  for ( uint64_t i = 0; i < nX; i++ ) { 
    uint64_t word_idx = i >> 6; /* divide by 64 */
    uint64_t  bit_idx = i & 0x3F; /* remainder after division by 64 */
    double rval = drand48();
    if ( rval <= p ) { 
      uint64_t bval = ( (uint64_t)1 << bit_idx );
      X[word_idx] |= bval;
      l_sum++;
    }
  }
  fprintf(stderr, "randB1: %llu, %lld, %lf \n", nX, l_sum, p);
BYE:
  return status;
}
