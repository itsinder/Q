#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "macros.h"
#include "eigenvectors.h"

int 
main(void) 
{
  int status = 0;

  uint64_t n = 3;
  double **X = NULL;
  X = malloc(n * sizeof(double *));
  return_if_malloc_failed(X);
  for ( uint64_t i = 0; i < n; i+=1 ) {
    X[i] = malloc(n * sizeof(double));
    return_if_malloc_failed(X[i]);
  }

  X[0][0] = 3;
  X[0][1] = 2;
  X[0][2] = 4;
  X[1][0] = 2;
  X[1][1] = 0;
  X[1][2] = 2;
  X[2][0] = 4;
  X[2][1] = 2;
  X[2][2] = 3;

  //X = {{3, 2, 4}, {2, 0, 2}, {4, 2, 3}};

  double *A = malloc(n*n* sizeof(double));
  return_if_malloc_failed(A);
  for (uint64_t i = 0; i < n; i++ ) { 
    for (uint64_t j = 0; j < n; j++ ) { 
      A[i * n + j] = X[i][j];
    }
  }

  double *W = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(W);

  status = eigenvectors(n, W, A);

  if(status != 0) {
    printf("ERROR something went wrong\n");
    return status;
  }

  for ( uint64_t i = 0; i < n; i+=1 ) {
    printf("begin eigenvector %" PRIu64 "\n", i);
    for ( uint64_t j = 0; j < n; j+=1 ) {
      printf("%lf ", A[i * n + j]);
    }
    printf("\n");
    printf("end eigenvector %" PRIu64 "\n", i);
  }

  printf("begin eigenvalues\n");
  for ( uint64_t i = 0; i < n; i+=1 ) {
    printf("%lf ", W[i]);
  }
  printf("\nend eigenvalues\n");

BYE:
  free(A);
  free(W);
  if ( X != NULL ) { 
    for ( int i = 0; i < n; i++ ) {
      free_if_non_null(X[i]);
    }
  }
  free_if_non_null(X);
  return status;
}
