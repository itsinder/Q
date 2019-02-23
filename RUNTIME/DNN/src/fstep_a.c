#include "q_incs.h"
#include "dnn_types.h"
#include "act_fns.h"

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
    uint8_t *d_in,   /* [n_in]  dropout for input layer */
    uint8_t *d_out,  /* [n_out] dropout for output layer */
    float **out_z, /* [n_out][nI] */
    float **out_a, /* [n_out][nI] */
    int32_t nI, 
    int32_t n_in,  /* j is index for  input streaming */
    int32_t n_out,  /* k is index for output streaming */
    __act_fn_t afn
   )
{
  int status = 0;

  // This loop is the "b + " part of the formula 
// TODO #pragma omp parallel for 
  for ( int k = 0; k < n_out; k++ ) {
    if ( d_out[k] == true ) { continue; }
    float *out_z_k = out_z[k];
    float b_k = b[k];
    for ( int i = 0; i < nI; i++ ) { 
      out_z_k[i] = b_k;
    }
  }
  for ( int j = 0; j < n_in; j++ ) {  // for each neuron in input
    if ( d_in[j] == true ) { continue; }
    float *in_j = in[j];
    float *W_j = W[j];
// #pragma omp parallel for 
    for ( int k = 0; k < n_out; k++ ) { // for each neuron in out_zput
      if ( d_out[k] == true ) { continue; }
      float w_jk = W_j[k];
      float *out_z_k = out_z[k];
      for ( int i = 0; i < nI; i++ ) {  // for batch size 
        out_z_k[i] += in_j[i] * w_jk; // TODO Check if FMA is working 
      }
      float *out_a_k = out_a[k];
      afn(out_z_k, nI, out_a_k);
    }
  }
  return status;
}
