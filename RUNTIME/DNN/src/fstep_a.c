#include "q_incs.h"
#include "fstep_a.h"

// This subroutine is best when n_out >> number of processors
// A single element of the input is in[0][i], in[1][i], ... in[n_in-1][i]
// A single element of the outnput is out[0][i], ... out[n_out-1][i]
// We use i as the index for each element in the batch 
// nI is the number of elements in the batch
// We use j as the index for each element in the input
// We use k as the index for each element in the output
// Given in, W, we update out
int fstep_a(
    float **in,  /* [n_in][nI] */
    float **W,   /* [n_in][n_out] */ /* TODO: Order to be debated */
    float *b,    /* bias[n_out] */
    float d_in,   /* dropout for input layer */
    float d_out,  /* dropout for output layer */
    float **out, /* [n_out][nI] */
    int32_t nI, 
    int32_t n_in,  /* j is index for  input streaming */
    int32_t n_out  /* k is index for output streaming */
   )
{
  int status = 0;

  // This loop is the "b + " part of the formula 
// TODO #pragma omp parallel for 
  for ( int k = 0; k < n_out; k++ ) {
    float *out_k = out[k];
    float b_k = b[k];
    for ( int i = 0; i < nI; i++ ) { 
      out_k[i] = b_k;
    }
  }
  for ( int j = 0; j < n_in; j++ ) { 
    float *in_j = in[j];
    float *W_j = W[j];
// TODO #pragma omp parallel for 
    for ( int k = 0; k < n_out; k++ ) {
      float w_jk = W_j[k];
      float *out_k = out[k];
      for ( int i = 0; i < nI; i++ ) { 
        out_k[i] += in_j[i] * w_jk; // TODO Check if FMA is working 
      }
    }
  }
  return status;
}
