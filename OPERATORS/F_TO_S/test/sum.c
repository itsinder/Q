#include <stdio.h>
#include "q_macros.h"
#include "_concat_I1_I2_I4.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
#define N 1048576
  double *Z = NULL;
  double rslt[1];
  Z = malloc(N * sizeof(double));
  return_if_malloc_failed(Z);
  for ( int i = 0; i < N; i++ ) { Z[i] = i+1; }

  rslt[0] = 0;
  status = _
  status = concat_I1_I2_I4(X, Y, N, NULL, Z); cBYE(status);
  for ( int i = 0; i < N; i++, vx++, vy++ ) { 
    if ( vx == 256 ) { vx = 0; }
    if ( vy == 65536 ) { vy = 0; }
    uint64_t vz = ( (uint64_t )vx << 16 ) | vy;
    if ( vz != Z[i] ) { 
      go_BYE(-1);
    }
  }  
  //--------------------------------

BYE:
  free_if_non_null(Z);
  return status;
}
