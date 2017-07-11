#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "macros.h"
#include "eigenvectors.h"
#include <lapacke.h>

int
eigenvectors(
             uint64_t n,
             double *W,
             double *A
            )
{
  int status = 0;

  char jobz = 'V'; /*want eigenvectors, use 'N' for eigenvalues only*/
  char uplo = 'U'; /*'U' for upper triangle of X, L for lower triangle of X*/
  int N = n;
  int LDA = N; /* dimensions of X = LDA by N*/
  
  status = LAPACKE_dsyev(LAPACK_COL_MAJOR, jobz, uplo, N, A, LDA, W);

  

BYE:
  return status;
}
