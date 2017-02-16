/* To build: 
 * gcc -std=gnu99 driver.c positive_solver.c -Wall -O4 -pedantic -o driver 
 * To execute:
 * ./driver <n> # for some positive integer n
 * */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>
#include "macros.h"
#include "aux_driver.h"
#include "positive_solver.h"
int 
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  double **A = NULL;
  double **AT = NULL; // A transpose
  double **AAT = NULL; // A times A transpose
  double **Aprime = NULL;
  double *x_expected = NULL;
  double *x = NULL; 
  double *b = NULL;
  double *bprime = NULL;
  double *b_solver = NULL; // since solver messes up original b
  int n = 0;
  srand48(RDTSC());
  fprintf(stderr, "Usage is ./driver <n> \n");
  switch ( argc ) { 
    case 2 : n = atoi(argv[1]); break;
    default : go_BYE(-1); break;
  }
  status = alloc_matrix(&A, n); cBYE(status);
  status = alloc_matrix(&AT, n); cBYE(status);
  status = alloc_matrix(&AAT, n); cBYE(status);

  /* Note that A is symmetric. We define top half */
  for ( int i = 0; i < n; i++ )  {
    for ( int j = i; j < n; j++ ) {
      A[i][j] = llabs(lrand48() % 4) + 1;
    }
  }
  /* Now we copy top right half to bottom left half */
  for ( int i = 0; i < n; i++ )  {
    for ( int j = 0; j < i; j++ ) {
      A[i][j] = A[j][i];
    }
  }
  transpose(A, AT, n);
  multiply(A, AT, AAT, n);
  b_solver = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(b_solver);
  bprime = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(bprime);
  b = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(b);
  x_expected = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(x_expected);
  // Initialize x
  for ( int i = 0; i < n; i++ )  {
    x_expected[i] = (lrand48() % 16) - 16/2;
  }
  multiply_matrix_vector(AAT, x_expected, n, b);
  status = convert_matrix_for_solver(AAT, n, &Aprime);
  //-- Solver modifies b in place. hence we make a copy
  for ( int i = 0; i < n; i++ ) { 
    b_solver[i] = b[i];
  }
  print_input(AAT, Aprime, x_expected, b_solver, n);
  x = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(x);
  status = positive_solver(Aprime, x, b_solver, n);
  cBYE(status);

  fprintf(stderr, "x from solver is [ ");
  for (int i=0; i < n; i++) {
    fprintf(stderr, " %lf ", x[i]);
  }
  fprintf(stderr, "].\nChecking commences \n");
  // Compute bprime
  multiply_matrix_vector(AAT, x, n, bprime);
  bool error = false;
  fprintf(stderr, "x(good) x(computed) b(good), b(solver) \n");
  for (int i=0; i < n; i++) {
    fprintf(stderr, " %lf %lf %lf %lf ", 
        x_expected[i], x[i], b[i], bprime[i]);
    if ( abs(bprime[i] - b[i]) < 0.001 ) { 
      fprintf(stderr, " MATCH \n");
    }
    else {
      error = true; 
      fprintf(stderr, " ERROR \n");
    }
  }
  if ( error ) {
    fprintf(stderr, "FAILURE\n");
  }
  else {
    fprintf(stderr, "SUCCESS\n");
  }
BYE:
  free_matrix(A, n);
  free_matrix(AT, n);
  free_matrix(AAT, n);
  if ( Aprime != NULL ) { 
    for ( int i = 0; i < n; i++ ) { 
      free_if_non_null(Aprime[i]);
    }
  }
  free_if_non_null(Aprime);
  free_if_non_null(x);
  free_if_non_null(x_expected);
  free_if_non_null(b);
  free_if_non_null(bprime);
  free_if_non_null(b_solver);
  return status;
}
/*
My initial checking failed. 

Andrew: Ok, the problem is that if A isn’t positive, there are
multiple solutions. Rather than checking that x is what you expect,
instead check that Ax = b There’s no reason why the algorithm would
come up with the same solution when it’s not unique And since these
random matrices aren’t being compelled to be positive, there will be
multiple solutions

Ramesh Subramonian: BTW, is this correct: A positive matrix is a matrix
in which all the elements are greater than zero.

Andrew Winkler: No, a positive matrix is one for which xtAx > 0 unless
x is 0

Ramesh Subramonian: ahah! remind me not to trust Google when I have a
professional mathematician to rely on!

*/
