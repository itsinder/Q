#include "sum_prod.h"

// uint64_t num_ops;

static inline void
_vvmul(
    float * restrict X,
    double * restrict Y,
    uint32_t n,
    double * restrict Z
    )
{
#pragma omp simd
  for ( uint32_t i = 0; i < n; i++ ) { 
    Z[i] = X[i] * Y[i];
    // num_ops++;
  }
}
 
static inline void
_sum(
    double * restrict X,
    uint32_t n,
    double *ptr_Y
    )
{
  double y = 0;
#pragma omp simd
  for ( uint32_t i = 0; i < n; i++ ) { 
    y += X[i];
    // num_ops++;
  }
  *ptr_Y = y;
}
 
int
sum_prod(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double *w, /* vector of length N */
    double **A /* M vectors of length M */
    )
{
  int status = 0;
  double *temp = NULL;
  temp = malloc(N * sizeof(double));
  return_if_malloc_failed(temp);
  int block_size = 16384; 

  // num_ops = 0;
  uint32_t nT = sysconf(_SC_NPROCESSORS_ONLN);
// #pragma omp parallel for 
  for ( uint64_t i = 0; i < M; i++ ) { 
    memset(A[i], '\0', M*sizeof(double));
    // num_ops += M;
  }

  for ( uint64_t i = 0; i < M; i++ ) { 
    float *Xi = X[i];
    double *Ai = A[i];
    _vvmul(Xi, w, N, temp);
    if ( nT > M-i ) { nT = M-i; }
// #pragma omp parallel for schedule(static, 1) num_threads(nT)
#pragma omp parallel for 
    for ( uint64_t j = i; j < M; j++ ) {
      double temp2[block_size];
      double sum = 0;
      int num_blocks = N / block_size;
      if ( ( num_blocks * block_size ) != (int)N ) { num_blocks++; }
      for ( int b = 0; b < num_blocks; b++ ) { 
        uint64_t lb = b * block_size;
        uint64_t ub = lb + block_size;
        if ( b == (num_blocks-1) ) { ub = N; }
        double rslt;
        _vvmul(X[j] +lb, temp+lb, (ub-lb), temp2);
        _sum(temp2, (ub-lb), &rslt);
        sum += rslt;
        // num_ops++;
      }
#pragma omp critical (_sum_prod)
      {
      Ai[j] = sum;
      }
    }
  }
//  fprintf(stderr, "Num Ops = %llu \n", num_ops);
BYE:
  free_if_non_null(temp);
  return status;
}

#ifdef STAND_ALONE_TEST
int
main(
    )
{
  int status = 0;
  uint64_t N = 128 * 1024;
  uint64_t M = 1024;
  double **A = NULL;
  float **X = NULL;
  double *w = NULL;

  w = malloc(N * sizeof(double));

  X = malloc(M * sizeof(float *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    X[i] = malloc(M * sizeof(float));
  }

  A = malloc(M * sizeof(double *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    A[i] = malloc(M * sizeof(double));
  }

  status = sum_prod(X, M, N, w, A);
BYE:
  return status;
}

#endif
