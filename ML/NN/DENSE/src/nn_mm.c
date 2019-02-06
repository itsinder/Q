
int(
    float **X, /* [m][nI] */
    float **W, /* [m][n] */
    float **Y, /* [n][nI] */
    int32_t nI,
    int32_t m,
    int32_t n
   )
{
  int status = 0;

  for ( j = 0; j < n; j++ ) {
    float *Y_j = Y[j];
    float b_j = b[j];
    for ( i = 0; i < nI; i++ ) { 
      Y_j[i] = b_j;
    }
    for ( int k = 0; k < m; k++ ) { 
      float w_kj = W[k][j];
      float *X_k = X[k];
      for ( int i = 0; i < nI; i++ ) { 
        Y_j[i] += X_k[i] * w_kj;
      }
    }
  }

BYE:
  return status;
}
