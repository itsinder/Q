#include <stdio.h>
#include <stdlib.h>
//#include "../src/tmpl_rand.h"
#include "_rand_I4.h"
//#include <stdbool.h>
//#include <stdint.h>

int
main()
{
  int status = 0;
  /*int status = 0;
  uint64_t n = 10;
  double *vec = (double*) malloc(n * sizeof(double));
  double lb = 1.3;
  double ub = 4.5;

  RANDOM_F8_REC_TYPE args;
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
  free(vec);*/
  //---------------------------------
//#ifdef LATER
  int n = 10;
  int len = 10;
  int32_t *y = (int32_t*) malloc(len * sizeof(int32_t));
  RAND_I4_REC_TYPE argsy;
  argsy.seed = 0;
  int lb = 0;
  int ub = n - 1;
  argsy.lb = lb;
  argsy.ub = ub;
  status = rand_I4(y, len, &argsy, true);
  int ctr[n]; for ( int i = 0; i < n; i++ ) { ctr[i]= 0; }
  for ( uint64_t i = 0; i < n; i++ ) {
    if ( y[i] < lb || y[i] > ub ) {
      printf("FAILURE\n");
      return status;
    }
    ctr[y[i]] += 1;
  }

  for ( uint64_t i = 0; i < n; i++ ) {
    printf("%d ", y[i]);
    printf("count %d\n", ctr[i]);
  }
  printf("\n");

  int num_bad = 0;
  for ( int i = 0; i < n; i++ ) {
    if ( ctr[i] < 1 || ctr[i] > 4 ) {
      //printf("WARNING: uniformity is a bit off\n");
      num_bad += 1;
    }
    else {
      printf("yay %d is good\n", i);
    }
  }
  printf("Num bad is %d\n", num_bad);
//#endif

  //---------------------------------
  return status;
}

