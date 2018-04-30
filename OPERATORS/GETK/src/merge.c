#include <stdio.h>
#include <stdint.h>

int merge_min(
    int32_t *X, /* [nX] */
    int nX,
    int32_t *Y, /* [nY] */
    int nY,
    int32_t *Z, /* [nX] */
    int *ptr_nZ
    )
{
  int status = 0;
  int xidx = 0, yidx = 0, zidx = 0;

  for ( ; zidx < nX; ) {
    if ( xidx >= nX ) {
      // copy whatever is needed from Y
      for ( ; yidx < nY; ) { 
        Z[zidx++] = Y[yidx++];
      }
      break;
    }
    if ( yidx >= nY ) {
      // copy whatever is needed from X
      for ( ; xidx < nX; ) { 
        Z[zidx++] = X[xidx++];
      }
      break;
    }
    if ( Y[yidx] < X[xidx] ) { 
      Z[zidx] = Y[yidx];
      yidx++;
    }
    else  {
      Z[zidx] = X[yidx];
      xidx++;
    }
    zidx++;
  }
  *ptr_nZ = zidx;
BYE:
  return status;
}
#define STAND_ALONE_TEST
#ifdef STAND_ALONE_TEST
int main(void)
{
  int status = 0;
  int n = 10;
  int32_t X[n];
  int32_t Y[n];
  int32_t Z[n];
  int m = 0;
  for ( int i = 0; i < n; i++ ) { X[i] = 2*i; }
  for ( int i = 0; i < n; i++ ) { Y[i] = 2*i+1; }
  status = merge_min(X, n, Y, n, Z, &m);
  for ( int i = 0; i < m; i++ ) { printf("%d: %d \n", i, Z[i]); }
BYE:
  return status;
}
#endif
