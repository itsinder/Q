/*
 * Andrew Winkler
It has the virtue of dramatic simplicity - there's no need to explicitly construct the cholesky decomposition, no need to do the explicit backsubstitutions.
Yet it's essentially equivalent to that more labored approach, so its performance/stability/memory, etc. should be at least as good.

*/

/* unless otherwise specified, these functions expect
   the lower (equivalently upper) triangular elements
   of a symmetric, positive semidefinite matrix A,
   e.g. if the matrix is
   [ 1, 2, 3 ]
   [ 2, 4, 5 ]
   [ 3, 5, 6 ]
   A should be
   A[0] = [ 1, 2, 3 ]
   A[1] = [    4, 5 ]
   A[2] = [       6 ]
 */

#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include <malloc.h>
#include "matrix_helpers.h"
#include "positive_solver.h"
#include "macros.h"
static int _positive_solver_rec(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  int status = 0;
  /// printf("The alpha is %f\n", A[0][0]);
  if (n < 1) { go_BYE(-1); }
  if (n == 1) {
    if (A[0][0] == 0.0) {
        if (b[0] != 0.0) { go_BYE(-1); }
        x[0] = 0.0;
        return 0;
    }
    x[0] = b[0] / A[0][0];
    return 0;
  }

  double * bvec = b + 1;
  double * Avec = A[0] + 1;
  double ** Asub = A + 1;
  double * xvec = x + 1;

  int m = n -1;

  if (A[0][0] != 0.0) {
    for(int j=0; j < m; j++){
      bvec[j] -= Avec[j] * b[0] / A[0][0];
      for(int i=0; i < m - j; i++)
        Asub[i][j] -= Avec[i] * Avec[i+j] / A[0][0];
    }
  } /* else check that Avec is 0 */

  status = _positive_solver_rec(Asub, xvec, bvec, m);
  cBYE(status);
  if ( status < 0 ) { return status; }

  if (A[0][0] == 0.0) {
      if (b[0] != 0.0) { go_BYE(-1); }  /* or close enough... */
      x[0] = 0.0;
      return status;
  }

  double p = 0;
  for ( int k = 0; k < m; k++ ) {
    p += Avec[k] * xvec[k];
  }

  x[0] = (b[0] - p) / A[0][0];

BYE:
  return status;
}

/* destructively updates its input.
 */
int posdef_positive_solver_fast(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  return _positive_solver_rec(A, x, b, n);
}

/* preserves its input.
 */
int posdef_positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  int status = 0;
  // create a copy of A and b
  double ** Acopy = NULL;
  double * bcopy = NULL;

  status = alloc_symm_matrix(&Acopy, n); cBYE(status);
  bcopy = malloc(n * sizeof(double));
  return_if_malloc_failed(bcopy);

  for ( int i = 0; i < n; i++ ) {
    for ( int j = 0; j < n-i; j++ ) {
      Acopy[i][j] = A[i][j];
    }
    bcopy[i] = b[i];
  }

  status = _positive_solver_rec(Acopy, x, bcopy, n);

BYE:
  free_matrix(Acopy, n);
  free_if_non_null(bcopy);
  return status;
}

/* expects the columns of a full matrix. preserves its input.
   up to caller to determine if solution is valid,
   since one is not guaranteed to exist.
 */
int positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  int status = 0;

  double ** AtA = NULL; // A transpose * A
  double * Atb = NULL; // A transpose * b
  status = alloc_symm_matrix(&AtA, n); cBYE(status);
  Atb = malloc(n * sizeof(double));
  return_if_malloc_failed(Atb);

  transpose_and_multiply(A, AtA, n);
  transpose_and_multiply_matrix_vector(A, b, n, Atb);
  status = posdef_positive_solver_fast(AtA, x, Atb, n); cBYE(status);

BYE:
  free_matrix(AtA, n);
  free(Atb);
  return status;
}
