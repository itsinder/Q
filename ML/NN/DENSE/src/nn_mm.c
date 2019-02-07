
int fstep_a(
    float **in, /* [m][nI] */
    float **W, /* [m][n] */
    float **out, /* [n][nI] */
    int32_t n_batch, 
    int32_t n_in, /* 3 */
    int32_t n_out /* 4 */
   )
{
  int status = 0;

  for ( j = 0; j < n_out; j++ ) {
    float *out_j = out[j];
    float b_j = b[j];
    for ( i = 0; i < nI; i++ ) { 
      out_j[i] = b_j;
    }
    for ( int i = 0; i < n_in; i++ ) { 
      float w_kj = W[k][j];
      float *in_k = in[k];
      for ( int i = 0; i < nI; i++ ) { 
        out_[i] += in_k[i] * w_kj;
      }
    }
  }
  for ( j = 0; j < n_out; j++ ) { 
    for ( int i = 0; i < nI; i++ ) { 
      out[i][j] = activation_function(out[i][j]);
    }
  }
BYE:
  return status;
}
