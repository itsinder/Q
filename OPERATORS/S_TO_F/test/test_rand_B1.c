#include <stdio.h>
#include <stdint.h>
#include "../inc/rand_B1.h"

int main(
    ) 
{
  int status = 0;
  int n = 1048576;
  uint64_t *X = (uint64_t *) malloc((n+1)*sizeof(uint64_t));
  for ( int i = 0; i < n+1; i++ ) {
    X[i] = 0;
  }
  RAND_B1_REC_TYPE args;
  double p = 0.01;
  args.seed = 0;
  args.probability = p;

  int m = n*64+3;
  status = rand_B1(X, m, &args, 0); cBYE(status);
  int actual_cnt = 0;
  for ( int i = 0; i < n+1; i ++ ) { 
    actual_cnt += __builtin_popcountll(X[i]);
  }
  int theoretical_cnt = (int)(m * args.probability);
  printf("m = %d, p = %lf, Theory = %d, Actual = %d \n", 
      m, p, theoretical_cnt, actual_cnt);
  if ( ( actual_cnt > theoretical_cnt * 1.01 ) || 
       ( actual_cnt < theoretical_cnt * 0.99 ) ) {
    go_BYE(-1);
  }

BYE:
  return status;
}
