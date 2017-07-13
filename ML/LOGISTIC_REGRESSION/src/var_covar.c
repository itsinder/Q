#include <time.h>
#include "var_covar.h"

uint64_t num_ops;

static inline void
_vvmul(
    float * restrict X,
    float * restrict Y,
    uint32_t n,
    double * restrict Z
    )
{
#pragma omp simd
  for ( uint32_t i = 0; i < n; i++ ) { 
    Z[i] = X[i] * Y[i];
    num_ops++;
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
    num_ops++;
  }
  *ptr_Y = y;
}
 
int
var_covar(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double **A /* M vectors of length M */
    )
{
  int status = 0;

  if ( X == NULL ) { go_BYE(-1); }
  if ( A == NULL ) { go_BYE(-1); }
  if ( M == 0 ) { go_BYE(-1); } 
  if ( N <= 1 ) { go_BYE(-1); } // else division by 0
  // set up parameters for blocking/multi-threading
  int block_size = 16384; 
  uint32_t nT = sysconf(_SC_NPROCESSORS_ONLN);
  int num_blocks = N / block_size;
  if ( ( num_blocks * block_size ) != (int)N ) { num_blocks++; }

#pragma omp parallel for 
  // initialize A to 0
  for ( uint64_t i = 0; i < M; i++ ) { 
    memset(A[i], '\0', M*sizeof(double));
    num_ops += M;
  }
  // set diagonal to 1
  for ( uint64_t i = 0; i < M; i++ ) { 
    A[i][i] = 1;
  }

  for ( uint64_t i = 0; i < M; i++ ) { 
    float *Xi = X[i];
    double *Ai = A[i];
    if ( nT > M-i ) { nT = M-i; }
    // #pragma omp parallel for schedule(static, 1) num_threads(nT)
    // #pragma omp parallel for 
    for ( uint64_t j = i+1; j < M; j++ ) {
      double temp2[block_size];
      double sum = 0;
      for ( int b = 0; b < num_blocks; b++ ) { 
        uint64_t lb = b * block_size;
        uint64_t ub = lb + block_size;
        if ( b == (num_blocks-1) ) { ub = N; }
        double rslt;
        _vvmul(X[j] +lb, Xi+lb, (ub-lb), temp2);
        _sum(temp2, (ub-lb), &rslt);
        sum += rslt;
        num_ops++;
      }
      // #pragma omp critical (_var_covar)
      {
        Ai[j] = sum;
      }
    }
  }
BYE:
  return status;
}

#define STAND_ALONE_TEST
#ifdef STAND_ALONE_TEST
/*
gcc -g $QC_FLAGS var_covar.c  -I../inc/ -I$HOME/WORK/Q/UTILS/inc/
*/
int
main(
    )
{
  int status = 0;
  uint64_t N = 1024;
  uint64_t M = 32;
  double **A = NULL;
  float **X = NULL;
  clock_t start_t, stop_t;
  num_ops = 0;

  X = malloc(M * sizeof(float *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    X[i] = malloc(N * sizeof(float));
  }

  A = malloc(M * sizeof(double *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    A[i] = malloc(M * sizeof(double));
  }
  for ( uint64_t i = 0; i < M; i++ ) { 
    for ( uint64_t j = 0; j < N; j++ ) { 
      X[i][j] = (i+j+1);
    }
  }

  system("date");
  start_t = clock();
  status = var_covar(X, M, N, A);
  stop_t = clock();
  system("date");
  fprintf(stderr, "Num clocks = %llu \n", (unsigned long long)stop_t - start_t);
  fprintf(stderr, "Num Ops = %llu \n", (unsigned long long)num_ops);
#ifdef CHECK_RESULTS
  for ( int ii = 0; ii < M; ii++ ) { 
    for ( int jj = 0; jj < M; jj++ ) { 
      double chk = 0;
      for ( unsigned int l = 0; l < N; l++ ) { 
        chk += (X[ii][l] * X[jj][l]);
      }
      if ( ( ( A[ii][jj] -  chk) / chk )  > 0.001 ) {
        fprintf(stderr, "chk = %lf, A = %lf \n", chk, A[ii][jj]);
        go_BYE(-1);
      }
    }
  }
#endif
BYE:
  return status;
}

 // gcc $QC_FLAGS sum_prod.c -I../inc/  -o a.out -I../../../UTILS/inc/

#endif
