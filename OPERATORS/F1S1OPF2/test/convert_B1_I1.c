#include "_convert_B1_I1.h"

int
convert_I1_I2(  
      const uint64_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      int8_t * out,
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

    uint8_t inv = mcr_get_bit(out[widx], bidx);
    
    if ( inv != 0 ) { inv = 1 }
    
    out[i] = inv;
  } 
  BYE:
  return status;
}
   
