#define WHEREAMI { fprintf(stderr, "Line %3d of File %s \n", __LINE__, __FILE__);  }
#define go_BYE(x) { WHEREAMI; status = x ; goto BYE; }

#include <stdio.h>
#include <stdint.h>

int merge_min(
    int32_t *X, /* [nX] */
    uint32_t nX,
    int32_t *Y, /* [nY] */
    uint32_t nY,
    int32_t *Z, /* [nZ] */
    uint32_t nZ,
    uint32_t *ptr_num_in_Z
    )
{
  int status = 0;
  int xidx = 0, yidx = 0, zidx = 0;

  // Basic checks on parameters
  if ( ( X == NULL ) && ( nX > 0 ) ) { go_BYE(-1); }
  if ( ( Y == NULL ) && ( nY > 0 ) ) { go_BYE(-1); }
  if ( ( Z == NULL ) || ( nZ == 0 ) ) { go_BYE(-1); }
  //-----------------------------------
  for ( ; zidx < nZ; ) {
    if ( xidx >= nX ) {
      // copy whatever is needed from Y
      for ( ; (( yidx < nY ) && ( zidx < nZ )); ) { 
        Z[zidx++] = Y[yidx++];
      }
      break;
    }
    if ( yidx >= nY ) {
      // copy whatever is needed from X
      for ( ; (( xidx < nX ) && ( zidx < nZ )); ) { 
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
  *ptr_num_in_Z = zidx;
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
  uint32_t nX = 10, nY = 10, nZ = 10, num_in_Z;
  for ( int i = 0; i < nX; i++ ) { X[i] = 2*i; }
  for ( int i = 0; i < nY; i++ ) { Y[i] = 2*i+1; }
  status = merge_min(X, nX, Y, nY, Z, nZ, &num_in_Z);
  for ( int i = 0; i < num_in_Z; i++ ) { printf("%d: %d \n", i, Z[i]); }
BYE:
  return status;
}
#endif
