#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>
#include<inttypes.h>
#include "q_macros.h"


typedef struct _reduce_mink_args {
    int32_t *dist_k;
    int32_t *goal_k;
    int32_t max;
    int32_t num_in_dist_k;
  } REDUCE_mink_ARGS;

extern int
mink(
   const int32_t * restrict ptr_dist, // distance vector
   uint64_t dist_len, // size of distance vector
   const int32_t * restrict ptr_goal, // goal vector
   int32_t k, // count of min values to maintain,
   void *ptr_in_args // structure maintaining k min distances and respective goals
   );
