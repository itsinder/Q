#include <stdio.h>
#include "q_macros.h"
#include "_sum_F8.h"
#include "_sum_sqr_I8.h"
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

  X = malloc(N * sizeof(double));
  return_if_malloc_failed(X);
  for ( int i = 0; i < N; i++ ) { X[i] = i+1; }
  //----------------------------
  REDUCE_F8_ARGS xargs;
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
  REDUCE_I8_ARGS yargs;
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
BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  return status;
}
