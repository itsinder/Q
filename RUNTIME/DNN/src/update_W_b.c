#include "q_incs.h"
#include "dnn_types.h"
#include "update_W_b.h"
int
update_W_b(
    float ***W,
    float ***dW,
    float **b,
    float **db,
    int nl,
    int *npl,
    float alpha // learning rate
    )
{
  int status = 0;
  // Updates the 'W' and 'b'
  // TODO: Why is upper bound nl-1 and not nl?
  for ( int l = 1; l < nl-1; l++ ) { // for layer, starting from one
    float **W_l  = W[l];
    float **dW_l = dW[l];
    float *b_l   = b[l];
    float *db_l  = db[l];
    // for neurons in layer l-1
// #pragma omp parallel for 
    for ( int jprime = 0; jprime < npl[l-1]; jprime++ ) { 
      float  *W_l_jprime =  W_l[jprime];
      float *dW_l_jprime = dW_l[jprime];
      // for neurons in layer l
// #pragma omp simd 
      for ( int j = 0; j < npl[l]; j++ ) { 
        W_l_jprime[j] -= ( alpha * dW_l_jprime[j] );
      }
      /* above is equivalent to below 
      for ( int j = 0; j < npl[l]; j++ ) { 
        *W_l_jprime++ -= ( alpha * *dW_l_jprime++ );
      }
      */
    }
// #pragma omp simd 
    for ( int j = 0; j < npl[l]; j++ ) { 
      b_l[j] -= ( alpha * db_l[j] );
    }
  }
BYE:
  return status;
}
