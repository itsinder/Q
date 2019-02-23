#include "q_incs.h"
#include "act_fns.h"

float 
sigmoid(
    float *x, 
    int n, 
    float *y
    ) 
{ 
  int status = 0;
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) { y[i] = -1 * x[i]; }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) { y[i] = exp(y[i]); }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) { y[i] = 1 + y[i]; }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) { y[i] = 1.0 / y[i]; }
  return status;
}
float 
identity(
    float *x, 
    int n, 
    float *y
    ) 
{ 
  int status = 0;
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) { y[i] = x[i]; }
  return status;
}
