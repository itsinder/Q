#include <stdio.h>
#include <stdlib.h>
#include "../src/tmpl_rand.h"
//#include <stdbool.h>
//#include <stdint.h>

int
main()
{
  int status = 0;
  uint64_t n = 10;
  double *vec = (double*) malloc(n * sizeof(double));
  double lb = 1.3;
  double ub = 4.5;

  RAND_F8_REC_TYPE args;
  args.seed = 0;
  args.lb = lb;
  args.ub = ub;
  status = random_F8(vec, n, &args, true);
  for ( uint64_t i = 0; i < n; i++ ) {
    if ( vec[i] < lb || vec[i] > ub) {
      printf("FAILURE\n");
      return status;
    }
  }
  printf("SUCCESS\n");
  return status;
}

