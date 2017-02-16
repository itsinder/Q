#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>
#include "macros.h"
#include "aux_driver.h"
/* some utilities */
extern void  free_matrix(
      double **A,
      int n
      )
{
  if ( A != NULL ) { 
    for ( int i = 0; i < n; i++ ) { 
      free_if_non_null(A[i]);
    }
  }
  free_if_non_null(A);
}
extern void multiply_matrix_vector(
    double **A, 
    double *x,
    int n,
    double *b
    )
{
  for ( int i = 0; i < n; i++ ) { 
    double sum = 0;
    for ( int j = 0; j < n; j++ ) { 
      sum += A[i][j] * x[j];
    }
    b[i] = sum;
  }
}
extern int 
alloc_matrix(
    double ***ptr_X, 
    int n
    )
{
  int status = 0;
  double **X = NULL;
  *ptr_X = NULL;
  X = (double **) malloc(n * sizeof(double*));
  return_if_malloc_failed(X);
  for ( int i = 0; i < n; i++ ) { X[i] = NULL; }
  for ( int i = 0; i < n; i++ ) { 
    X[i] = (double *) malloc(n * sizeof(double));
    return_if_malloc_failed(X[i]);
  }
  *ptr_X = X;
BYE:
  return status;
}
extern void 
multiply(
    double **A,
    double **B,
    double **C,
    int n
    )
{
  for ( int i = 0; i < n; i++ ) { 
    for ( int j = 0; j < n; j++ ) { 
      double sum = 0;
      for ( int k = 0; k < n; k++ ) { 
        sum += A[i][k] * B[k][j];
      }
      C[i][j] = sum;
    }
  }
}

extern void 
transpose(
    double **A,
    double **B,
    int n
    )
{
  for ( int i = 0; i < n; i++ ) { 
    for ( int j = 0; j < n; j++ ) { 
      B[i][j] = A[j][i];
    }
  }
}

extern void
print_input(
    double **A, 
    double **Aprime,
    double *x, 
    double *b, 
    int n
    )
{
  for ( int i = 0; i < n; i++ ) { 
    fprintf(stderr, "[ ");
    for ( int j = 0; j < n; j++ ) { 
      if ( j == 0 ) { 
        fprintf(stderr, " %2d ", (int)(int)A[i][j]);
      }
      else {
        fprintf(stderr, ", %2d ", (int)A[i][j]);
      }
    }
    fprintf(stderr, "] ");
    // print x
    fprintf(stderr, " [ ");
    fprintf(stderr, " %2d ", (int)x[i]);
    fprintf(stderr, "] ");
    // print b
    fprintf(stderr, "  = [ ");
    fprintf(stderr, " %3d ", (int)b[i]);
    fprintf(stderr, "] ");
    // print Aprime
    for ( int j = 0; j < n-i; j++ ) { 
      fprintf(stderr, " %2d ", (int)Aprime[i][j]);
    }

    fprintf(stderr, "\n");
  }
}
/* assembly code to read the TSC */
uint64_t 
RDTSC(void)
{
  unsigned int hi, lo;
  __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}
int
convert_matrix_for_solver(
    double **A,
    int n,
    double ***ptr_Aprime
    )
{
  int status = 0;
  double **Aprime = NULL;
  /* The solver does not want a full matrix. So, we must convert A 
     to Aprime, which is allocated and initialized differently. */
  Aprime = (double **) malloc(n * sizeof(double*));
  return_if_malloc_failed(Aprime);
  for ( int i = 0; i < n; i++ ) { Aprime[i] = NULL; }
  for ( int i = 0; i < n; i++ ) { 
    Aprime[i] = (double *) malloc((n-i) * sizeof(double));
    return_if_malloc_failed(Aprime[i]);
  }
  //---------------------------
  for ( int i = 0; i < n; i++ ) { 
    for ( int j = 0; j < n-i; j++ ) { 
      Aprime[i][j] = A[i][j+i];
    }
  }
  *ptr_Aprime = Aprime;
BYE:
  return status;
}
