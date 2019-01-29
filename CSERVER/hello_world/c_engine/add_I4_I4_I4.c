#include "add_I4_I4_I4.h"

int
add_I4_I4_I4(
    int *X,
    int *Y,
    int n,
    int *Z
    )
{
  int status = 0;
#pragma omp parallel for
  for ( int i = 0; i < n; i++ ) { 
    Z[i] = X[i] + Y[i];
  }
  return status;
}
