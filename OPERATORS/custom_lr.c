int
lr_custom(  
  double *X,
  double *Y,
  double *Z,
  uint64_t n,
  double **A, /* A[i] is column i */
  uint32_t m,
  uint32_t cache_size
  )
  {
    for ( uint32_t i = 0; i < m; i++ ) { 
      for ( uint32_t j = 0; j < m; j++ ) { 
        A[i][j] = 0;
      }
    }
    for ( int b = 0; b < num_blocks; b++ ) { 
      for ( int i = 0; i < m; i++ ) { 
        for ( int j = i+1; i < m; i++ ) { 
          double sum = 0;
          for ( int l = lb; l < ub; l++ ) { 
            sum += (X[l] * Y[l] * Z[l]);
          }
          A[j][k] = sum;
        }
      }
    }
      for ( uint32_t j = 0; j < m; j++ ) { 
        A[i][j] = 0;
      }
    }
BYE:
    return status;
  }
