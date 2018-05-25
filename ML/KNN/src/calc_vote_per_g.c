#include <math.h>
#include "q_incs.h"
#include "calc_vote_per_g.h"

double
safe_exp(
    double x
    )
{
  if ( x > 308 ) {
    return DBL_MAX;
  }
  else {
    return exp(x);
  }
}

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
  float bot[1000]; // TODO FIX 
  float top[1000]; // TODO FIX 
  float min_vote = FLT_MAX;
  float max_vote = -1.0 * FLT_MAX;
  static bool first = true;
  for ( int j = 0; j < n_test; j++ ) { 
    o_test[j] = 0;
  }
  if ( first ) { 
    bot[0] = 0.009889;
    bot[1] = 0.00000;
    bot[2] = 0.011702;
    bot[3] = 0.009413;
    bot[4] = 0.000091;

    top[0] = 5.355901;
    top[1] = 1.216016;
    top[2] = 4.638428;
    top[3] = 4.377539;
    top[4] = 0.805968;

    first = false;
  }
  else {
    bot[0] = 0.012634;
    bot[1] = 0.000659;
    bot[2] = 0.009671;
    bot[3] = 0.023537;
    bot[4] = 0.020499;

    top[0] = 6.830450;
    top[1] = 0.217153;
    top[2] = 2.111241;
    top[3] = 7.726687;
    top[4] = 9.213053;
  }
  for ( int i = 0; i < 5; i++ ) { bot[i] = 0; }

  float exponent = 4.0; // TODO FIX P1
  float scale = 64;
  for ( int j = 0; j < n_test; j++ ) { 
    for ( int k = 0; k < n_train; k++ ) { 
      float sum = 0;
      for ( int i = 0; i < m; i++ ) { 
        float test_val = d_test[i][j];
        float train_val = d_train[i][k];
        float x1 = test_val - train_val;
        float x2 = x1 * x1;
        float x3;
        if ( x2 < bot[i] ) { x3 = 0; }
        else if ( x2 > top[i] ) { x3 = scale; }
        else { x3 = ((x2 - bot[i])/top[i]) * scale; }
        x3 = x2;
        sum += x3;
      }
      if ( exponent != 1 ) { 
        sum = pow(sum, exponent);
      }
      float vote_k = 1.0 / (1.0 + sum);
      /*
      float vote_k = 1.0 / safe_exp(exponent * sum);
      */

      min_vote = mcr_min(min_vote, vote_k);
      max_vote = mcr_max(min_vote, vote_k);
      o_test[j] += vote_k;
    }
  }
  fprintf(stderr, "min/max vote = %f, %f \n", min_vote, max_vote);
BYE:
  return status;
}
