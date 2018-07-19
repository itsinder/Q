#include "mink.h"

int
mink(
   const int32_t * restrict ptr_dist, // distance vector
   uint64_t dist_len, // size of distance vector
   const int32_t * restrict ptr_goal, // goal vector
   int32_t k, // count of min values to maintain, 
   void *ptr_in_args // structure maintaining k min distances and respective goals
   )

{
  int status = 0;

  if ( ptr_dist == NULL ) { go_BYE(-1); }
  if ( dist_len == 0 ) { go_BYE(-1); }
  if ( ptr_goal == NULL ) { go_BYE(-1); }
  if ( k == 0 ) { go_BYE(-1); }
  if ( ptr_in_args == NULL ) { go_BYE(-1); }
  if ( k > dist_len ) { go_BYE(-1); }

  REDUCE_mink_ARGS *ptr_args;
  ptr_args = (REDUCE_mink_ARGS *) ptr_in_args;

  int32_t dist_val;
  int32_t goal_val;
  
  for ( int i = 0; i < dist_len; i++ ) {
    dist_val = ptr_dist[i];
    goal_val = ptr_goal[i];

    if ( ptr_args->num_in_dist_k == 0 ) {
      ptr_args->dist_k[0] = dist_val;
      ptr_args->goal_k[0] = goal_val;
      ptr_args->max = dist_val;
      ptr_args->num_in_dist_k++;
      continue;
    }

    if ( ( ptr_args->num_in_dist_k < k ) || ( dist_val < ptr_args->max ) ) {
      for ( int j = 0; j < ptr_args->num_in_dist_k; j++ ) {
        if ( ptr_args->dist_k[j] > dist_val ) {
          // Swap element
          int32_t temp_dist = ptr_args->dist_k[j];
          int32_t temp_goal = ptr_args->goal_k[j];
          ptr_args->dist_k[j] = dist_val;
          ptr_args->goal_k[j] = goal_val;
          dist_val = temp_dist;
          goal_val = temp_goal;
        }
      }
      if ( ptr_args->num_in_dist_k < k ) {
        ptr_args->dist_k[ptr_args->num_in_dist_k] = dist_val;
        ptr_args->goal_k[ptr_args->num_in_dist_k] = goal_val;
        ptr_args->max = dist_val;
        ptr_args->num_in_dist_k++;
      } 
      else {
        ptr_args->max = ptr_args->dist_k[k-1];
      }
    }
  }

BYE:
  return status;
}


int main() {
  int32_t MAX = 2147483647;
  int status = 0;
  int size = 20;

  int32_t k = 4;

  int32_t *dist_buf, *goal_buf;
  dist_buf = malloc(size * sizeof("int32_t"));
  goal_buf = malloc(size * sizeof("int32_t"));
  for ( int i = 0; i < size; i++ ) {
    dist_buf[i] = i+1;
    goal_buf[i] = 0;
  }
  dist_buf[18] = 2;
  dist_buf[14] = 1;
  dist_buf[5] = 3;

  goal_buf[1] = 1;
  goal_buf[2] = 1;
  goal_buf[5] = 1;
  goal_buf[14] = 1;
  goal_buf[3] = 1;

  printf("Inputs are \n");
  for ( int i = 0; i < size; i++ ) {
    printf("%d\t%d\n", dist_buf[i], goal_buf[i]);
  }

  // Struct initialization
  REDUCE_mink_ARGS *ptr_args;
  ptr_args = malloc(sizeof("REDUCE_mink_ARGS"));
  ptr_args->dist_k = malloc(k * sizeof("int32_t"));
  ptr_args->goal_k = malloc(k * sizeof("int32_t"));
  
  // Initialize struct
  ptr_args->max = MAX;
  ptr_args->num_in_dist_k = 0;
  for ( int i = 0; i < k; i++ ) {
    ptr_args->dist_k[i] = 0;
    ptr_args->goal_k[i] = 0;
  }


  // Call mink
  for ( int i = 0; i < 2; i++ ) {
    dist_buf = dist_buf + ( i * ( size / 2 ) );
    goal_buf = goal_buf + ( i * ( size / 2 ) );
    status = mink(dist_buf, size/2, goal_buf, k, ptr_args);
  }

  //status = mink(dist_buf, size, goal_buf, k, ptr_args);

  printf("Mink status = %d\n", status);
  printf("k distances and respective goals are\n");
  for ( int i = 0; i < k; i++ ) {
    printf("%d\t%d\n", ptr_args->dist_k[i], ptr_args->goal_k[i]);
  }
  printf("max = %d\n", ptr_args->max);

  return status;
}

