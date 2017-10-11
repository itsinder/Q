#include "q_incs.h"
#include <strings.h>
#include <math.h>
#include "_where_I4.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int nA = 10;
  int32_t *A = NULL;
  int64_t *B = NULL;
  int32_t *C = NULL;
  uint64_t nC = 0;
  
  //----------------------------
  A = malloc(nA * sizeof(int32_t));
  return_if_malloc_failed(A);
  for ( int i = 0; i < nA; i++ ) {
    A[i] = ( i + 1 ) * 10;
  }  
  
  //----------------------------
  B = malloc(ceil( nA / 8 ));
  return_if_malloc_failed(B);
  B[0] = 10;    // Only two set bits (1) in B
  
  //----------------------------
  C = malloc(nA * sizeof(int32_t));
  return_if_malloc_failed(C);
  for ( int i = 0; i < nA; i++ ) {
    C[i] = 0;
  }
  
  status = where_I4(A, B, nA, C, &nC); cBYE(status);

  printf("Size of Output is %d\n", nC);
  
  if ( nC != 2 ) {
    printf("Length Mismatch\n");
    printf("C: ERROR\n");
    status = -1;
    cBYE(status);
  }

  for ( int i = 0; i < nC; i++ ) {
    if ( C[i] != (i + 1) * 20 ) {
      printf("Value Mismatch at index %d\n", i);
      printf("C: ERROR\n");
      status = -1;
      cBYE(status);
    }
    printf("%d\n", C[i]);
  }  
  printf("C: SUCCESS\n");
BYE:
  free_if_non_null(A);
  free_if_non_null(B);
  free_if_non_null(C);
  return status;
}
