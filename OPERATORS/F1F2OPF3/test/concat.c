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
  int8_t *X = NULL;
  int16_t *Y = NULL;
  int32_t *Z = NULL;
  //--------------------------------
  int8_t vx = 0;
  X = malloc(N * sizeof(int8_t));
  return_if_malloc_failed(X);
  for ( int i = 0; i < N; i++, vx++ ) { 
    if ( vx == 256 ) { vx = 0; }
    X[i] = vx;
  }
  //--------------------------------
  int16_t vy = 0;
  Y = malloc(N * sizeof(int16_t));
  return_if_malloc_failed(Y);
  for ( int i = 0; i < N; i++, vy++ ) { 
    if ( vy == 65536 ) { vy = 0; }
    Y[i] = vy;
  }
  //--------------------------------
  vx = vy = 0;
  Z = malloc(N * sizeof(int32_t));
  return_if_malloc_failed(Z);
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
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  return status;
}
