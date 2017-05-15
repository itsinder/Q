/* To execute:
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

/* testing and benchmarking for AxEqualsB solver.
 * generates a random matrix A, and tests the positive semidefinite solver
 * by running iton AtA and tests the full solver by running it on A.
 *
 * the current method of generating random matrices isn't perfect, but it's
 * better than it seems because solving Ax = b is independent of any scaling
 * factor, so the size of the matrix is irrelevant.
 */

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int n = 0;                    // dimension of matrices
  double **A = NULL;            // randomly generated n * n matrix
  double **AtA = NULL;          // A transpose times A
  double **AtA_copy = NULL;     // copy for testing solver that modifies input
  double *x_expected = NULL;    // randomly generated solution
  double *x_posdef_slow = NULL; // solution returned by slow compact form posdef solver
  double *x_posdef_fast = NULL; // solution returned by fast compact from posdef solver
  double *x_full = NULL;        // solution returned by full, non-posdef solver
  double *b_posdef = NULL;      // AtA * x_expected
  double *b_posdef_copy = NULL; // copy for testing solver that modifies input
  double *b_posdef_slow = NULL; // AtA * x_posdef_slow
  double *b_posdef_fast = NULL; // AtA * x_posdef_fast
  double *b_full = NULL;        // A * x_expected
  double *b_full_ret = NULL;    // A * x_full
  srand48(RDTSC());
  fprintf(stderr, "Usage is ./driver <n> \n");
  switch ( argc ) {
    case 2 : n = atoi(argv[1]); break;
    default : go_BYE(-1); break;
  }
  status = alloc_matrix(&A, n); cBYE(status);
  status = alloc_symm_matrix(&AtA, n); cBYE(status);
  status = alloc_symm_matrix(&AtA_copy, n); cBYE(status);

  for ( int i = 0; i < n; i++ )  {
    for ( int j = 0; j < n; j++ ) {
      A[i][j] = (drand48() - 0.5) * 100;
    }
  }
  transpose_and_multiply(A, AtA, n);
  b_posdef = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef);
  b_posdef_copy = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef_copy);
  b_posdef_slow = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef_slow);
  b_posdef_fast = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef_fast);
  b_full = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_full);
  b_full_ret = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_full_ret);
  x_expected = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(x_expected);
  x_posdef_slow = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(x_posdef_slow);
  x_posdef_fast = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(x_posdef_fast);
  x_full = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(x_full);

  // Initialize x and b
  for ( int i = 0; i < n; i++ )  {
    x_expected[i] = (lrand48() % 16) - 16/2;
  }
  multiply_symm_matrix_vector(AtA, x_expected, n, b_posdef);
  multiply_matrix_vector(A, x_expected, n, b_full);

  // make copies manually so we can test functions that modify their input
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n - i; j++) {
      AtA_copy[i][j] = AtA[i][j];
    }
    b_posdef_copy[i] = b_posdef[i];
  }

  print_input(AtA, x_expected, b_posdef, n);

  // time computations for each solver
  clock_t begin_slow = clock();
  status = posdef_positive_solver(AtA, x_posdef_slow, b_posdef, n);
  clock_t end_slow = clock();
  cBYE(status);
  double time_spent_slow = (double)(end_slow - begin_slow) / CLOCKS_PER_SEC;

  clock_t begin_fast = clock();
  status = posdef_positive_solver_fast(AtA_copy, x_posdef_fast, b_posdef_copy, n);
  clock_t end_fast = clock();
  cBYE(status);
  double time_spent_fast = (double)(end_fast - begin_fast) / CLOCKS_PER_SEC;

  clock_t begin_full = clock();
  status = positive_solver(A, x_full, b_full, n);
  clock_t end_full = clock();
  cBYE(status);
  double time_spent_full = (double)(end_full - begin_full) / CLOCKS_PER_SEC;

  // Compute new bs for comparison
  multiply_symm_matrix_vector(AtA, x_posdef_slow, n, b_posdef_slow);
  multiply_symm_matrix_vector(AtA, x_posdef_fast, n, b_posdef_fast);
  multiply_matrix_vector(A, x_full, n, b_full_ret);

  // check for errors and print output
  bool slow_posdef_error = false;
  bool fast_posdef_error = false;
  bool full_error = false;
  fprintf(stderr, "x(orig) x(PD_slow) x(PD_fast) x(full), b(PD_good) b(PD_slow) b(PD_fast) b(full) b(full_ret) \n");
  for (int i=0; i < n; i++) {
    fprintf(stderr, " %lf %lf %lf %lf, %lf %lf %lf %lf %lf ",
            x_expected[i], x_posdef_slow[i], x_posdef_fast[i], x_full[i],
            b_posdef[i], b_posdef_slow[i], b_posdef_fast[i], b_full[i], b_full_ret[i]);
    if ( abs(b_posdef_slow[i] - b_posdef[i]) < 0.001 ) {
      fprintf(stderr, " SLOW_POSDEF_MATCH, ");
    }
    else {
      slow_posdef_error = true;
      fprintf(stderr, " SLOW_POSDEF_ERROR, ");
    }
    if ( abs(b_posdef_fast[i] - b_posdef[i]) < 0.001 ) {
      fprintf(stderr, "FAST_POSDEF_MATCH, ");
    }
    else {
      fast_posdef_error = true;
      fprintf(stderr, "FAST_POSDEF_ERROR,  ");
    }
    if ( abs(b_full_ret[i] - b_full[i]) < 0.001 ) {
      fprintf(stderr, "FULL_MATCH\n");
    }
    else {
      full_error = true;
      fprintf(stderr, "FULL_ERROR\n ");
    }
  }
  fprintf(stderr, slow_posdef_error ? "SLOW_POSDEF_FAILURE, " : "SLOW_POSDEF_SUCCESS, ");
  fprintf(stderr, fast_posdef_error ? "FAST_POSDEF_FAILURE, " : "FAST_POSDEF_SUCCESS, ");
  fprintf(stderr, full_error ? "FULL_FAILURE\n" : "FULL_SUCCESS\n");
  fprintf(stderr, "slow solver took %0.4fs, fast solver took %0.4fs, normal solver took %0.4fs\n",
          time_spent_slow, time_spent_fast, time_spent_full);

BYE:
  free_matrix(A, n);
  free_matrix(AtA, n);
  free_matrix(AtA_copy, n);
  free_if_non_null(x_posdef_slow);
  free_if_non_null(x_posdef_fast);
  free_if_non_null(x_full);
  free_if_non_null(x_expected);
  free_if_non_null(b_posdef);
  free_if_non_null(b_posdef_copy);
  free_if_non_null(b_posdef_slow);
  free_if_non_null(b_posdef_fast);
  free_if_non_null(b_full);
  free_if_non_null(b_full_ret);
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

static void
print_input(
            double **A,
            double *x,
            double *b,
            int n
            )
{
  for ( int i = 0; i < n; i++ ) {
    fprintf(stderr, "[ ");
    for ( int j = 0; j < n; j++ ) {
      if ( j == 0 ) {
        fprintf(stderr, " %2d ", (int)index_symm_matrix(A, i, j));
      }
      else {
        fprintf(stderr, ", %2d ", (int)index_symm_matrix(A, i, j));
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

    fprintf(stderr, "\n");
  }
}

/* assembly code to read the TSC */
static uint64_t
RDTSC(void)
{
  unsigned int hi, lo;
  __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}
