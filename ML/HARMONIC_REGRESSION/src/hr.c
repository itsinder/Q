#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <string.h>
#include <limits.h>
#include <inttypes.h>
#include <ctype.h>
#include "q_macros.h"
#include "mmap.h"
#include "aux_driver.h"
#include "positive_solver.h"

#define PI 3.141592

bool
is_valid_chars_for_num(
      char * const X
      )
{
  if ( ( X == NULL ) || ( *X == '\0' ) ) { WHEREAMI; return false; }
  for ( char *cptr = X; *cptr != '\0'; cptr++ ) { 
    if ( isdigit(*cptr) || 
        ( *cptr == '-' )  ||
        ( *cptr == '.' ) ) {
      continue;
    }
    return false;
  }
  return true;
}
//------------------------------
int
txt_to_F8(
      char * const X,
      double *ptr_out
      )
{
  int status = 0;
  char *endptr = NULL;
  double out;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  if ( !is_valid_chars_for_num(X) ) { go_BYE(-1); }
  out = strtold(X, &endptr);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  if ( endptr == X ) { go_BYE(-1); }
  if ( ( out < DBL_MIN ) || ( out > DBL_MAX ) ) { go_BYE(-1); }
  *ptr_out = (double)out;
 BYE:
  return status ;
}

//------------------------------
int
load_col_csv(
    char *infile,
    double **ptr_X,
    int *ptr_nX
    )
{
  int status = 0;
  char buf[32];
  char *Y = NULL; size_t nY = 0;
  double *X = NULL; int nX = 0; double tempF8;
  status = rs_mmap(infile, &Y, &nY, 0); cBYE(status);
  for ( int i = 0; i < nY; i++ ) { 
    if ( Y[i] == '\n' ) { nX++; }
  }
  if ( nX == 0 ) { go_BYE(-1); }
  X = malloc(nX * sizeof(double));
  return_if_malloc_failed(X);
  int bufidx = 0; int yidx = 0; int xidx = 0;
  memset(buf, '\0', 32); 
  for ( ; ; yidx++ ) { 
    if ( yidx >= nY ) { go_BYE(-1); }
    if ( Y[yidx] == '\n' ) {
      status = txt_to_F8(buf, &tempF8); cBYE(status);
      X[xidx++] = tempF8;
      if ( xidx == nX ) { break; }
      bufidx = 0;
      memset(buf, '\0', 32); 
    }
    else {
      if ( bufidx == 32 ) { go_BYE(-1); }
      buf[bufidx++] = Y[yidx];
    }
  }
  *ptr_X  = X;
  *ptr_nX = nX;
BYE:
  rs_munmap(Y, nY);
  return status;
}

int
main(
    int argc,
    char **argv
    )

{
  int status = 0;
  double *X = NULL; int nT = 0;
  double *Y = NULL; 
  double *Z = NULL; 
  double *W = NULL; double **U = NULL;
  double **A = NULL;
  double *a = NULL; double *b = NULL;
  double **Aprime = NULL;
  double *gamma = NULL;
  double *rho = NULL;
  FILE *ofp = NULL;
  int nJ = 15; // number of functions used

  if ( argc != 3 ) { go_BYE(-1); }
  char *infile = argv[1];
  char *opfile = argv[2];
  ofp = fopen(opfile, "w");
  if ( strcmp(infile, opfile) == 0 ) { go_BYE(-1); }
  return_if_fopen_failed(ofp, opfile, "w");
  status = load_col_csv(infile, &X, &nT); cBYE(status);
  U = malloc(nJ * sizeof(double *));
  return_if_malloc_failed(U);
  for ( int j = 0; j < nJ; j++ ) { 
    U[j] = malloc(nT * sizeof(double));
    return_if_malloc_failed(U[j]);
  }

  //-------------------------------------
  Y = malloc(nT * sizeof(double));
  return_if_malloc_failed(Y);
  for ( int i = 0; i < nT; i++ ) { 
    Y[i] = log(X[i]);
  }
  //-------------------------------------
  Z = malloc(nT * sizeof(double));
  return_if_malloc_failed(Z);
  Z[0] = Y[0];
  for ( int i = 1; i < nT; i++ ) { 
    Z[i] = Y[i] - Y[i-1];
  }
  //-------------------------------------
  for ( int i = 0; i < nT; i++ ) { 
    U[0][i] = 1;
  }
  for ( int j = 1; j <= 7; j++ ) { 
    for ( int t = 0; t < nT; t++ ) { 
      U[j][t] = cos ( 2 * PI * j * t / 7 );
    }
  }
  for ( int j = 8; j <= 14; j++ ) { 
    for ( int t = 0; t < nT; t++ ) { 
      U[j][t] = sin ( 2 * PI * (j-7) * t / 7 );
    }
  }
  //-------------------------------------
  //  Create symmetric matrix A
  status = alloc_matrix(&A, nJ); cBYE(status);
  for ( int j1 = 0; j1 < nJ; j1++ ) { 
    for ( int j2 = 0; j2 < nJ; j2++ ) { 
      double sum = 0;
      for ( int t = 0; t < nT; t++ ) { 
        sum += ( U[j1][t] * U[j2][t] );
      }
      A[j1][j2] = sum;
    }
  }
  //-------------------------------------
  //  Create b
  b = malloc(nJ * sizeof(double));
  return_if_malloc_failed(b);
  for ( int j = 0; j < nJ; j++ ) { 
    double sum = 0;
    for ( int t = 0; t < nT; t++ ) { 
      sum += Z[t] * U[j][t];
    }
    b[j] = sum;
  }
  //-------------------------------------
  // Solve for a 
  a = malloc(nJ * sizeof(double));
  return_if_malloc_failed(a);
  for ( int j = 0; j < nJ; j++ ) { a[j] = 0; }

  status = convert_matrix_for_solver(A, nJ, &Aprime); cBYE(status);
  // print_input(A, Aprime, a, b, nJ);
  status = positive_solver(Aprime, a, b, nJ); cBYE(status);
  // vVerify solution 
  for ( int j = 0; j < nJ; j++ ) { 
    double sum = 0;
    for ( int j2 = 0; j2 < nJ; j2++ ) { 
      sum += A[j][j2] * a[j2];
    }
    double minval = min(sum, b[j]);
    if ( ( sum/b[j] > 1.01 ) || ( sum / b[j] < 0.09 ) ) {
      printf("Error on a[%d]: %lf versus %lf \n", j, sum, b[j]);
    }
  }
  //---------------------------------
  W = malloc(nT * sizeof(double));
  return_if_malloc_failed(W);
  for ( int t = 0; t < nT; t++ ) { 
    double sum = 0;
    for ( int j = 0; j < nJ; j++ ) { 
      sum += (a[j] * U[j][t]);
    }
    W[t] = Z[t] -  sum;
  }
  for ( int t = 0; t < nT; t++ ) {
    fprintf(ofp, "%lf\n", W[t]);
  }
  //--------------------------------
  double mu = 0;
  for ( int t = 0; t < nT; t++ ) { 
    mu += W[t];
  }
  mu /= nT;
  go_BYE(0); 
  //--------------------------------
  gamma = malloc(nT * sizeof(double));
  return_if_malloc_failed(gamma);
  for ( int t = 0; t < nT; t++ ) { 
    rho[t] = gamma[t] / gamma[0];
  }
  //----------------------
  rho = malloc(nT * sizeof(double));
  return_if_malloc_failed(rho);


  printf("ALL DONE\n");
BYE:
  free_matrix(A, nJ);
  if ( Aprime != NULL ) {
    for ( int j = 0; j < nJ; j++ ) { 
      free_if_non_null(Aprime[j]);
    }
  }
  free_if_non_null(Aprime);
  if ( U != NULL ) {
    for ( int j = 0; j < nJ; j++ ) { 
      free_if_non_null(U[j]);
    }
  }
  fclose_if_non_null(ofp);
  free_if_non_null(U);
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  free_if_non_null(W);
  free_if_non_null(a);
  free_if_non_null(b);
  free_if_non_null(gamma);
  free_if_non_null(rho);
  return status;
}
