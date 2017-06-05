#include <stdio.h>
#include "q_macros.h"
#include "_expF8.h"
#include "_logF8.h"
#include <math.h>
int
main(
    )
{
  int status = 0;
#define N 100
  double *X = NULL;
  double *Y = NULL;
  double *Z = NULL;
  //--------MALLOC X----------------
  X = malloc(N * sizeof(double));
  return_if_malloc_failed(X);
  double vx = 1.3;
  for ( int i = 0; i < N; i++ ) {
    X[i] = vx;
    vx = vx + 1.0;
  }
  //---------MALLOC Y AND Z----------------
  Y = malloc(N * sizeof(double));
  return_if_malloc_failed(Y);
  Z = malloc(N * sizeof(double));
  return_if_malloc_failed(Y);
  //-----------TESTING-------------
  status = expF8(X, N, Y);
  status = logF8(Y, N, Z);
  double threshold = 0.01;

  for ( int i = 0; i < N; i++ ) {
    if ( fabs(X[i] - Z[i] ) > threshold ) {
      printf("FAILURE\n");
      return 1;
    }
  }
  printf("SUCCESS\n");
BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  return status;
}
