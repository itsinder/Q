#include "q_incs.h"
#include "mmap_types.h"
#include "vec.h"

int
main()
{
  int status = 0;
#define NUM_TRIALS 1000
  for ( int i = 0; i < NUM_TRIALS; i++ ) { 
    VEC_REC_TYPE *X = vec_new("I4", 4, 8192);
    status = vec_nascent(X); cBYE(status);
    status = vec_free(X); cBYE(status);
  }
BYE:
  if ( status == 0 ) { 
    fprintf(stderr, "SUCCESS\n"); 
  }
  else { 
    fprintf(stderr, "FAILUER\n"); 
  }
  return status;
}
