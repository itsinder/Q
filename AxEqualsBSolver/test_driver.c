/* To execute:
 * ./driver <n> # for some positive integer n
 * */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>
#include <time.h>
#include <lapacke.h>
#include "macros.h"
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

static void
_print_input(
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
_RDTSC(void)
{
  unsigned int hi, lo;
  __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}

static void
_print_result(double *x_expected, double *x_returned,
              double *b_expected, double *b_returned,
              char *name, bool verbose, int n, double runtime)
{
  bool error = false;
  fprintf(stderr, "CHECKING %s RESULTS\n", name);
  if (verbose) {
    fprintf(stderr, "x(expect), x(%s), b(expect), b(%s)\n", name, name);
  }
  for (int i=0; i < n; i++) {
    if (verbose) {
      fprintf(stderr, " %lf, %lf, %lf, %lf",
              x_expected[i], x_returned[i], b_expected[i], b_returned[i]);
    }

    if ( abs(b_returned[i] - b_expected[i]) < 0.001 ) {
      if (verbose) {
        fprintf(stderr, " %s_MATCH\n", name);
      }
    }
    else {
      error = true;
      if (verbose) {
        fprintf(stderr, " %s_ERROR\n", name);
      }
    }
  }
  if (error) {
    fprintf(stderr, "%s_FAILURE", name);
  } else {
    fprintf(stderr, "%s_SUCCESS", name);
  }
  fprintf(stderr, " in %0.4fs\n\n", runtime);
}

static int
run_lapack_tests(
    double **A,
    double *x_expected,
    double *b,
    double **AtA,
    double *b_AtA,
    int n,
    bool verbose
    )
{
  int status = 0;
  lapack_int N = n;
  lapack_int NRHS = 1;
  lapack_int LDA = N;
  lapack_int LDB = N;

  double *A_unrolled = NULL;
  double *AtA_unrolled = NULL;
  double *b_copy = NULL;
  double *b_AtA_copy = NULL;
  double *b_returned = NULL;
  lapack_int *ipiv = NULL;

  A_unrolled = malloc(n * n * sizeof(double)); return_if_malloc_failed(A_unrolled);
  AtA_unrolled = malloc(n * n * sizeof(double)); return_if_malloc_failed(AtA_unrolled);
  b_copy = malloc(n * sizeof(double)); return_if_malloc_failed(b_copy);
  b_AtA_copy = malloc(n * sizeof(double)); return_if_malloc_failed(b_AtA_copy);
  b_returned = malloc(n * sizeof(double)); return_if_malloc_failed(b_returned);
  ipiv = malloc(n * sizeof(lapack_int)); return_if_malloc_failed(ipiv);

  for (int i = 0; i < n; i++) {
    b_copy[i] = b[i];
    b_AtA_copy[i] = b_AtA[i];
    for (int j = 0; j < n; j++) {
      A_unrolled[n * i + j] = A[i][j];
    }
    for (int j = 0; j <= i; j++) {
      AtA_unrolled[n * i + j] = AtA[j][i - j];
    }
    for (int j = i + 1; j < n; j++) {
      AtA_unrolled[n * i + j] = 0;
    }
  }

  clock_t begin = clock();
  LAPACKE_dgesv(LAPACK_COL_MAJOR, N, NRHS, A_unrolled, LDA, ipiv, b_copy, LDB);
  double runtime = (double)(clock() - begin) / CLOCKS_PER_SEC;
  multiply_matrix_vector(A, b_copy, n, b_returned);
  _print_result(x_expected, b_copy, b, b_returned, "LAPACK_FULL", verbose, n, runtime);

  begin = clock();
  LAPACKE_dposv(LAPACK_COL_MAJOR, 'U', N, NRHS, AtA_unrolled, LDA, b_AtA_copy, LDB);
  runtime = (double)(clock() - begin) / CLOCKS_PER_SEC;
  multiply_symm_matrix_vector(AtA, b_AtA_copy, n, b_returned);
  _print_result(x_expected, b_AtA_copy, b_AtA, b_returned, "LAPACK_POSDEF", verbose, n, runtime);

BYE:
  free_if_non_null(A_unrolled);
  free_if_non_null(AtA_unrolled);
  free_if_non_null(b_copy);
  free_if_non_null(b_AtA_copy);
  free_if_non_null(b_returned);
  free_if_non_null(ipiv);

  return status;
}

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int n = 0;                       // dimension of matrices
  int verbose = 0;
  double **A = NULL;               // randomly generated n * n matrix
  double **AtA = NULL;             // A transpose times A
  double **AtA_copy = NULL;        // copy for testing solver that modifies input
  double **AtA_full = NULL;        // A transpose times A
  double *x_expected = NULL;       // randomly generated solution
  double *x_returned = NULL;       // solution returned by full, non-posdef solver
  double *b_posdef = NULL;         // AtA * x_expected
  double *b_posdef_copy = NULL;    // copy for testing solver that modifies input
  double *b_full = NULL;           // A * x_expected
  double *b_returned = NULL;       // A * x_expected
  srand48(_RDTSC());
  fprintf(stderr, "Usage is ./driver <n> [-v] \n");
  switch ( argc ) {
  case 3 : verbose = strcmp("-d", argv[2]) == 0;
  case 2 : n = atoi(argv[1]); break;
  default : go_BYE(-1); break;
  }
  status = alloc_matrix(&A, n); cBYE(status);
  status = alloc_symm_matrix(&AtA, n); cBYE(status);
  status = alloc_symm_matrix(&AtA_copy, n); cBYE(status);
  status = alloc_matrix(&AtA_full, n); cBYE(status);

  for ( int i = 0; i < n; i++ )  {
    for ( int j = 0; j < n; j++ ) {
      A[i][j] = (drand48() - 0.5) * 100;
    }
  }
  transpose_and_multiply(A, AtA, n);
  b_posdef = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef);
  b_posdef_copy = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef_copy);
  b_full = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_full);
  b_returned = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_returned);
  x_expected = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(x_expected);
  x_returned = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(x_returned);

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
      AtA_full[i][i + j] = AtA[i][j];
      AtA_full[i + j][i] = AtA[i][j];
    }
    b_posdef_copy[i] = b_posdef[i];
  }

  if (verbose) {
    _print_input(AtA, x_expected, b_posdef, n);
  }

  clock_t begin, end;
  double runtime;

  // time computations for each solver
  begin = clock();
  status = posdef_positive_solver(AtA, x_returned, b_posdef, n); cBYE(status);
  end = clock();
  runtime = (double)(end - begin) / CLOCKS_PER_SEC;
  multiply_symm_matrix_vector(AtA, x_returned, n, b_returned);
  _print_result(x_expected, x_returned, b_posdef, b_returned, "POSDEF_SLOW", verbose, n, runtime);

  begin = clock();
  status = posdef_positive_solver_fast(AtA_copy, x_returned, b_posdef_copy, n); cBYE(status);
  end = clock();
  runtime = (double)(end - begin) / CLOCKS_PER_SEC;
  multiply_symm_matrix_vector(AtA, x_returned, n, b_returned);
  _print_result(x_expected, x_returned, b_posdef, b_returned, "POSDEF_FAST", verbose, n, runtime);

  begin = clock();
  status = full_posdef_positive_solver(AtA_full, x_returned, b_posdef, n);
  end = clock();
  cBYE(status);
  multiply_symm_matrix_vector(AtA, x_returned, n, b_returned);
  runtime = (double)(end - begin) / CLOCKS_PER_SEC;
  _print_result(x_expected, x_returned, b_posdef, b_returned, "FULL_POSDEF_SLOW", verbose, n, runtime);

  for (int i = 0; i < n; i++) {
    b_posdef_copy[i] = b_posdef[i];
  }
  begin = clock();
  status = full_posdef_positive_solver_fast(AtA_full, x_returned, b_posdef_copy, n);
  end = clock();
  cBYE(status);
  multiply_symm_matrix_vector(AtA, x_returned, n, b_returned);
  runtime = (double)(end - begin) / CLOCKS_PER_SEC;
  _print_result(x_expected, x_returned, b_posdef, b_returned, "FULL_POSDEF_FAST", verbose, n, runtime);

  begin = clock();
  status = positive_solver(A, x_returned, b_full, n);
  end = clock();
  cBYE(status);
  multiply_matrix_vector(A, x_returned, n, b_returned);
  runtime = (double)(end - begin) / CLOCKS_PER_SEC;
  _print_result(x_expected, x_returned, b_full, b_returned, "FULL", verbose, n, runtime);

  run_lapack_tests(A, x_expected, b_full, AtA, b_posdef, n, verbose);

BYE:
  free_matrix(A, n);
  free_matrix(AtA, n);
  free_matrix(AtA_copy, n);
  free_matrix(AtA_full, n);
  free_if_non_null(x_expected);
  free_if_non_null(x_returned);
  free_if_non_null(b_posdef);
  free_if_non_null(b_posdef_copy);
  free_if_non_null(b_full);
  free_if_non_null(b_returned);
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
