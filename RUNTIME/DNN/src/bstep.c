#include "q_incs.h"
#include "dnn_types.h"
#include "act_fns.h"

#include "bstep.h"

// TODO: Add pragma omp at appropriate places

int generate_da_last(
    float **a,   /* 'a' value for last layer */
    float **out,   /* Xout */
    float **da,   /* 'da' value for last layer */
    int n_in_last,   /* number of neurons in last layer */
    int batch_size
    )
{
  int status = 0;

  for ( int j = 0; j < n_in_last; j++ ) { // for neurons in last layer
    float *out_j = out[j];
    float *a_j   = a[j];
    float *da_j  = da[j];
#pragma omp parallel for schedule(static, 16)
    // 16 is so that if cache line is 64 bytes and float is 4 bytes
    // then threads do not stomp on each other
    for ( int i = 0; i < batch_size; i++ ) { // for each instance
      da_j[i] = ( ( 1 - out_j[i] ) / ( 1 - a_j[i] ) ) 
        - ( out_j[i] / a_j[i] );
    }
  } // 'da' for last layer has been computed
BYE:
  return status;
}

//================================================================
/*
For backward propagation,
    in_layer --> current layer (l)
    out_layer -> previous layer (l-1)
*/
int bstep(
    float **z, /* 'z' at in_layer */
    float **a_prev, /* 'a' at out_layer */
    float **W, /* 'W' at in_layer */
    float **da, /* 'da' at in_layer */
    float **dz, /* 'dz' at in_layer */
    float **da_prev, /* 'da' at out_layer */
    float **dW, /* 'dW' at in_layer */
    float *db, /* 'db' at in_layer */
    int32_t n_in, /* neurons in in_layer */
    int32_t n_out, /* neurons in out_layer */
    int32_t batch_size,
    __bak_act_fn_t afn
    )
{
  int status = 0;

  // I think it might make sense to compute dW and db even if we don't 
  // use them because of the dropout
  // This loop will produce the dz, dW, db & da_prev values
  for ( int j = 0; j < n_in; j++ ) { // for neurons in in_layer
    // ----------- START - generate dz -----------
    float *z_j = z[j];
    float *da_j = da[j];
    float *dz_j = dz[j];
    status = afn(z_j, da_j, batch_size, dz_j); cBYE(status);
    // ----------- STOP - generate dz -----------

    // ----------- START - generate da_prev -----------
    if ( da_prev != NULL ) { // avoid computing da[0], which is NULL
      for ( int jprime = 0; jprime < n_out; jprime++ ) { // for neurons in out_layer
        float *W_jprime = W[jprime];
        float *da_prev_jprime = da_prev[jprime];
        for ( int i = 0; i < batch_size; i++ ) {
          da_prev_jprime[i] += dz_j[i] * W_jprime[j];
          // TODO Check FMA working
        }
      }
    }
    // ----------- STOP - generate da_prev -----------

    // ----------- START - generate dW & db -----------
    float sum = 0;
    for ( int jprime = 0; jprime < n_out; jprime++ ) { 
      // for neurons in out_layer
      sum = 0;
      float *a_prev_jprime = a_prev[jprime];
#pragma omp simd
      for ( int i = 0; i < batch_size; i++ ) {
        sum += dz_j[i] * a_prev_jprime[i]; // TODO Check FMA working
      }
      sum /= batch_size;
      dW[jprime][j] = sum;
    }
    sum = 0;
#pragma omp simd reduction(+:sum)
    for ( int i = 0; i < batch_size; i++ ) {
      sum += dz_j[i];
    }
    sum /= batch_size;
    db[j] = sum;
    // ----------- STOP - generate dW & db -----------
  }
  
BYE:
  return status;
}
