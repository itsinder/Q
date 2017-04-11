#include "q_incs.h"
#include <strings.h>
#include "_ainb_I4_I8.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int nA = 524288+17;
  int nB = 4096+1;
  int32_t *A = NULL;
  int64_t *B = NULL;
  uint64_t *X = NULL; 
  int nX = nA/64; if ( ( nX * 64 ) != nA ) { nX++; }

  //----------------------------
  A = malloc(nA * sizeof(int32_t));
  return_if_malloc_failed(A);
  int aidx = 1;
  for ( int i = 0; i < nA; i++ ) { 
    A[i] = aidx++; 
    if ( aidx == 64 ) { aidx = 0; }
  }
  //----------------------------
  B = malloc(nB * sizeof(int64_t));
  return_if_malloc_failed(B);
  int bidx = 1;
  for ( int i = 0; i < nB; i++ ) { 
    B[i] = bidx++; 
    if ( bidx == 32 ) { aidx = 0; }
  }
  //----------------------------
  X = malloc(nX * sizeof(uint64_t));
  return_if_malloc_failed(X);
  //----------------------------
  status = ainb_I4_I8(A, nA, B, nB, X); cBYE(status);
  if ( 0 ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  int mX = 0;
  for ( int i = 0; i < nX; i++ ) { 
    mX += __builtin_popcountll(X[i]);
  }
  fprintf(stderr, "mX = %d \n", mX);
  //----------------------------
BYE:
  free_if_non_null(A);
  free_if_non_null(B);
  free_if_non_null(X);
  return status;
}
