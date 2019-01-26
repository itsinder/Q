#include "q_incs.h"
#include "dummy.h"
#include "add_I4_I4_I4.h"
int
dummy(
    const char *const args,
    const char *const body
    )
{
  int status = 0;
  int N = 1048576; // TODO P2 get this from args
  int *X = NULL;
  int *Y = NULL;
  int *Z = NULL;
  X = malloc(N * sizeof(int)); return_if_malloc_failed(X);
  Y = malloc(N * sizeof(int)); return_if_malloc_failed(Y);
  Z = malloc(N * sizeof(int)); return_if_malloc_failed(Z);
  for ( int i = 0; i < N; i++ ) { 
    X[i] = i;
    Y[i] = -1 * i;
    Z[i] = INT_MAX;
  }
  // Do not make direct call --> add_I4_I4_I4(X, Y, N,  Z); cBYE(status);
BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  return status;
}
