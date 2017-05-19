#include <stdio.h>
#include "q_macros.h"
#include "_sum_F8.h"
#include "_sum_sqr_I8.h"
#include "_min_I4.h"
#include "_max_I1.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int N = 524288+17;
  double *X = NULL;
  int64_t *Y = NULL;
  int32_t *Z = NULL;
  int8_t *W = NULL;

  X = malloc(N * sizeof(double));
  return_if_malloc_failed(X);
  for ( int i = 0; i < N; i++ ) { X[i] = i+1; }
  //----------------------------
  REDUCE_sum_F8_ARGS xargs;
  xargs.cum_val = 0;
  status = sum_F8(X, N, &xargs, 0); cBYE(status);
  double dN = (double)N;
  if ( xargs.cum_val != (dN*(dN+1)/2.0) ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //----------------------------
  Y = malloc(N * sizeof(int64_t));
  return_if_malloc_failed(Y);
  for ( int i = 0; i < N; i++ ) { Y[i] = i+1; }
  REDUCE_sum_sqr_I8_ARGS yargs;
  yargs.cum_val = 0;
  status = sum_sqr_I8(Y, N, &yargs, 0); cBYE(status);
  uint64_t lN = (uint64_t)N;
  if ( yargs.cum_val != (lN*(lN+1)*(2*lN+1)/6) ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //----------------------------
  Z = malloc(N * sizeof(int32_t));
  return_if_malloc_failed(Z);
  for ( int i = 0; i < N; i++ ) { Z[i] = i+1; }
  REDUCE_min_I4_ARGS zargs;
  zargs.cum_val = INT_MAX;
  status = min_I4(Z, N, &zargs, 0); cBYE(status);
  if ( zargs.cum_val != 1 ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //----------------------------
  W = malloc(N * sizeof(int8_t));
  return_if_malloc_failed(W);
  for ( int i = 0; i < N; i++ ) { W[i] = i; }
  REDUCE_max_I1_ARGS wargs;
  wargs.cum_val = SCHAR_MIN;
  status = max_I1(W, N, &wargs, 0); cBYE(status);
  if ( wargs.cum_val != SCHAR_MAX ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  free_if_non_null(W);
  return status;
}
