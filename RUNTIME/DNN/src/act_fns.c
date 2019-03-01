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
float 
relu(
    float *x, 
    int n, 
    float *y
    ) 
{ 
  int status = 0;
  for ( int  i = 0; i < n; i++ ) { 
    if ( x[i] < 0 ) { 
      y[i] = 0;
    }
    else {
      y[i] = x[i]; 
    }
  }
  return status;
}
// https://stackoverflow.com/questions/34968722/how-to-implement-the-softmax-function-in-python
float 
softmax(
    float *x, 
    int n, 
    float *y
    ) 
{ 
  int status = 0;
#pragma omp simd 
  for ( int  i = 0; i < n; i++ ) { y[i] = exp(x[i]); }
  float sum = 0;
#pragma omp simd reduction(+:sum)
  for ( int  i = 0; i < n; i++ ) { 
    sum += y[i];
  }
#pragma omp simd 
  for ( int  i = 0; i < n; i++ ) { y[i] = y[i] / sum; }
  return status;
}
