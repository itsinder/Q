#include <math.h>
#include "q_incs.h"
#include "calc_vote_per_g.h"

int 
calc_vote_per_g(
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
    o_test[j] = 0;
  }

  float exponent = 4.0; // TODO FIX P1
  for ( int j = 0; j < n_test; j++ ) { 
    for ( int k = 0; k < n_train; k++ ) { 
      float vote_k;
      float sum = 0;
      for ( int i = 0; i < m; i++ ) { 
        float x3;
        float test_val = d_test[i][j];
        float train_val = d_train[i][k];
        float x1 = test_val - train_val;
        float x2 = x1 * x1;
        x3 = x2;
        sum += x3;
      }
      if ( exponent != 1 ) { sum = pow(sum, exponent); }
      vote_k = 1.0 / (1.0 + sum);
      o_test[j] += vote_k;
    }
  }
BYE:
  return status;
}
