/* To build:
 * gcc -std=gnu99 driver.c positive_solver.c -Wall -O4 -pedantic -o driver
 * To execute:
 * ./driver <n> # for some positive integer n
 * */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>
#include <time.h>
#include "macros.h"
#include "aux_driver.h"
#include "matrix_helpers.h"
#include "positive_solver.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  double **A = NULL;
  double **AAT = NULL; // A times A transpose
  double **AATcopy = NULL;
  double *x_expected = NULL;
  double *x_slow = NULL;
  double *x_fast = NULL;
  double *b = NULL;
  double *bcopy = NULL;
  double *b_slow = NULL;
  double *b_fast = NULL;
  int n = 0;
  srand48(RDTSC());
  fprintf(stderr, "Usage is ./driver <n> \n");
  switch ( argc ) {
    case 2 : n = atoi(argv[1]); break;
    default : go_BYE(-1); break;
  }
  status = alloc_symm_matrix(&A, n); cBYE(status);
  status = alloc_symm_matrix(&AAT, n); cBYE(status);
  status = alloc_symm_matrix(&AATcopy, n); cBYE(status);

  for ( int i = 0; i < n; i++ )  {
    for ( int j = 0; j < n - i; j++ ) {
      A[i][j] = (drand48() - 0.5) * 100;
    }
  }
  square_symm_matrix(A, AAT, n);
  b = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(b);
  bcopy = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(bcopy);
  b_slow = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(b_slow);
  b_fast = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(b_fast);
  x_expected = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(x_expected);
  x_slow = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(x_slow);
  x_fast = (double *) malloc(n * sizeof(double));
  return_if_malloc_failed(x_fast);
  // Initialize x
  for ( int i = 0; i < n; i++ )  {
    x_expected[i] = (lrand48() % 16) - 16/2;
  }
  multiply_symm_matrix_vector(AAT, x_expected, n, b);

  // make copies manually so we can compare performance of fast and slow versions
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n - i; j++) {
      AATcopy[i][j] = AAT[i][j];
    }
    bcopy[i] = b[i];
  }

  print_input(AAT, x_expected, b, n);
  clock_t begin_slow = clock();
  status = positive_solver(AAT, x_slow, b, n);
  cBYE(status);
  clock_t end_slow = clock();
  double time_spent_slow = (double)(end_slow - begin_slow) / CLOCKS_PER_SEC;

  clock_t begin_fast = clock();
  status = positive_solver_fast(AATcopy, x_fast, bcopy, n);
  cBYE(status);
  clock_t end_fast = clock();
  double time_spent_fast = (double)(end_fast - begin_fast) / CLOCKS_PER_SEC;


  fprintf(stderr, "x from slow solver is [ ");
  for (int i=0; i < n; i++) {
    fprintf(stderr, " %lf ", x_slow[i]);
  }
  fprintf(stderr, "].\nx from fast solver is [ ");
  for (int i=0; i < n; i++) {
    fprintf(stderr, " %lf ", x_fast[i]);
  }
  fprintf(stderr, "].\nChecking commences \n");
  // Compute new bs
  multiply_symm_matrix_vector(AAT, x_slow, n, b_slow);
  multiply_symm_matrix_vector(AAT, x_fast, n, b_fast);
  bool slow_error = false;
  bool fast_error = false;
  fprintf(stderr, "x(good) x(slow) x(fast), b(good) b(slow) b(fast) \n");
  for (int i=0; i < n; i++) {
    fprintf(stderr, " %lf %lf %lf, %lf %lf %lf ",
            x_expected[i], x_slow[i], x_fast[i], b[i], b_slow[i], b_fast[i]);
    if ( abs(b_slow[i] - b[i]) < 0.001 ) {
      fprintf(stderr, " SLOW_MATCH, ");
    }
    else {
      slow_error = true;
      fprintf(stderr, " SLOW_ERROR, ");
    }
    if ( abs(b_fast[i] - b[i]) < 0.001 ) {
      fprintf(stderr, "FAST_MATCH\n");
    }
    else {
      fast_error = true;
      fprintf(stderr, "FAST_ERROR\n ");
    }
  }
  if ( slow_error ) {
    fprintf(stderr, "SLOW_FAILURE, ");
  }
  else {
    fprintf(stderr, "SLOW_SUCCESS, ");
  }
  if ( fast_error ) {
    fprintf(stderr, "FAST_FAILURE\n");
  }
  else {
    fprintf(stderr, "FAST_SUCCESS\n");
  }
  fprintf(stderr, "slow solver took %0.4fs, fast solver took %0.4fs\n", time_spent_slow, time_spent_fast);
BYE:
  free_matrix(A, n);
  free_matrix(AAT, n);
  free_matrix(AATcopy, n);
  free_if_non_null(x_slow);
  free_if_non_null(x_fast);
  free_if_non_null(x_expected);
  free_if_non_null(b);
  free_if_non_null(bcopy);
  free_if_non_null(b_slow);
  free_if_non_null(b_fast);
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
