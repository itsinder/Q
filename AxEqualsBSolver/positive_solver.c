/* 
 * Andrew Winkler
It has the virtue of dramatic simplicity - there's no need to explicitly construct the cholesky decomposition, no need to do the explicit backsubstitutions.
Yet it's essentially equivalent to that more labored approach, so its performance/stability/memory, etc. should be at least as good.

*/
#include <stdlib.h>
#include <stdio.h>
#define WHEREAMI { fprintf(stderr, "Line %3d of File %s \n", __LINE__, __FILE__);  }
#define go_BYE(x) { WHEREAMI; status = x ; goto BYE; }
#define cBYE(x) { if ( (x) < 0 ) { go_BYE((x)) } }
#include "positive_solver.h"
static int _positive_solver(
    double ** A, 
    double * b, 
    double * x, 
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

  status = _positive_solver(Asub, bvec, xvec, m);
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

#include <malloc.h>
int positive_solver(
    double ** A, 
    double *x,
    double * b, 
    int n
    ) 
{
  int status = 0;
  status = _positive_solver(A, b, x, n); cBYE(status);
BYE:
  return status;
}
