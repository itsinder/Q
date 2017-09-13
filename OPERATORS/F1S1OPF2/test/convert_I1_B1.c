#include "_convert_I1_B1.h"

int
convert_I1_I2(  
      const int8_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      uint64_t * out,
      uint64_t *nn_out
      )

{
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }

#pragma omp parallel for 
  for ( uint64_t i = 0; i < nR; i++ ) { 
    // Get word index and bit index
    uint64_t widx = i >> 8; // word index
    uint64_t bidx = i & 0xFF; // bit index

    int8_t inv = in[i];
    
    if (inv == 0 || inv == 1) {
      mcr_set_bit(out[widx], bidx);
    } else {
      go_BYE(-1);
    }
  } 
  BYE:
  return status;
}
   
