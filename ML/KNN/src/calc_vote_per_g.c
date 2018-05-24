#include "q_incs.h"
#include "calc_vote_per_g.h"

int calc_vote_per_g(
    float **d_train, /* [m][n_train] */
    int m,
    int n_train,
    float *alpha, /* [m] */
    float **d_test, /* [m][n_test] */
    int n_test,
    float *o_test /* [n_test] */
    )
{
  int status = 0;
  for ( int j = 0; j < n_test; j++ ) { 
    o_test[j] = 1;
  }

// #pragma omp parallel for 
  for ( int i = 0; i < m; i++ ) { 
    float *d_train_i = d_train[i];
    float alpha_i = alpha[i];
    float *d_test_i  = d_test[i];
    for ( int j = 0; j < n_test; j++ ) { 
      float test_val = d_test_i[j];
      float sum = 0;
      // #pragma omp simd
      for ( int k = 0; k < n_train; k++ ) { 
        float train_val = d_train_i[j];
        float x = (train_val - test_val);
        x *= x;
        x *= alpha_i;
        sum += x;
      }
      o_test[j] += sum;
    }
  }
  for ( int j = 0; j < n_test; j++ ) { 
    o_test[j] = 1.0 / o_test[j];
  }
BYE:
  return status;
}
