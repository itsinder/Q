// gcc -O4 par_sort.c qsort_asc_I4.c -fopenmp -lgomp -I../../../UTILS/inc/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>
#include "qsort_asc_I4.h"
#include "q_incs.h"
static uint64_t RDTSC( void)
{
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  // config parameters
  uint64_t n = 1 * 1048576;
  int num_bins = 32;
  //-- allocations needed for following
  int32_t **lX = NULL;
  uint64_t *ub = NULL;
  uint64_t *num_in_bin = NULL;
  uint64_t *cum_num_in_bin = NULL;
  int32_t *X = NULL;
  // other variables
  uint64_t t_start, t_stop; // malloc and initialize data 
  X = malloc(n * sizeof(int32_t));
  return_if_malloc_failed(X);
  for ( int i = 0; i < n; i++ ) { X[i] = rand(); }
  //---------------------------------
  // Allocate space for each bin
  int bin_size = (int)((float)n / (float)num_bins  * 1.1);

  lX = malloc(num_bins * sizeof(int32_t *));
  return_if_malloc_failed(lX);
  for ( int b = 0; b < num_bins; b++ ) { lX[b] = NULL; }

  num_in_bin = malloc(num_bins * sizeof(uint64_t));
  return_if_malloc_failed(num_in_bin);

  num_in_bin = malloc(num_bins * sizeof(uint64_t));
  return_if_malloc_failed(num_in_bin);

  cum_num_in_bin = malloc(num_bins * sizeof(uint64_t));
  return_if_malloc_failed(cum_num_in_bin);

  ub = malloc(num_bins * sizeof(uint64_t));
  return_if_malloc_failed(ub);

  for ( int b = 0; b < num_bins; b++ ) { 
    num_in_bin[b] = 0;
    lX[b] = malloc(bin_size * sizeof(int32_t));
    return_if_malloc_failed(lX[b]);
  }
  // START: This is a hack to estimate quantiles
  for ( int b = 0; b < num_bins; b++ ) { 
    ub[b] = (uint64_t)((float)(RAND_MAX) / (float)num_bins * (b+1));
  }
  ub[num_bins-1] = INT_MAX;
  // STOP : This is a hack to estimate quantiles
  // Copy each element from input into its correct bin
  t_start = RDTSC();
  for ( uint64_t i = 0; i < n; i++ ) { 
    int32_t val = X[i];
    int bidx = 0;
    for ( int b = 0; b < num_bins; b++ ) {
      if ( val <= ub[b] ) { bidx = b; break; }
    }
    uint64_t where_to_put = num_in_bin[bidx];
    // printf("Placing %d in %d of %d \n", i, where_to_put, bidx);
    lX[bidx][where_to_put] = val;
    num_in_bin[bidx] = where_to_put + 1;
  }
  t_stop = RDTSC();
  printf("move time  = %" PRIu64 "\n", t_stop - t_start);
  t_start = RDTSC();
#pragma omp parallel for 
  for ( int b = 0; b < num_bins; b++ ) {
    qsort_asc_I4 (lX[b], num_in_bin[b]);
  }
  t_stop = RDTSC();
  printf("psort time = %" PRIu64 "\n", t_stop - t_start);
  // Copy everything back to original location
  // convert num_in_bin to cumulative count
  cum_num_in_bin[0] = 0;
  for ( int b = 1; b < num_bins; b++ ) { 
    cum_num_in_bin[b] = cum_num_in_bin[b-1] + num_in_bin[b-1];
  }
  t_start = RDTSC();
#pragma omp parallel for 
  for ( int b = 0; b < num_bins; b++ ) {
    int32_t *addr = X + cum_num_in_bin[b];
    memcpy(addr, lX[b], sizeof(int32_t) * num_in_bin[b]);
  }
  t_stop = RDTSC();
  printf(" move time = %" PRIu64 "\n", t_stop - t_start);
  // put some random numbers and do sequential sort
  for ( int i = 0; i < n; i++ ) { X[i] = rand(); }
  t_start = RDTSC();
  qsort_asc_I4 (X, n);
  t_stop = RDTSC();
  printf(" seq  time = %" PRIu64 "\n", t_stop - t_start);

BYE:
  free_if_non_null(X);
  if ( lX != NULL ) { 
    for ( int b = 0; b < num_bins; b++ ) { 
      free_if_non_null(lX[b]);
    }
  }
    free_if_non_null(lX);

  free_if_non_null(num_in_bin);
  free_if_non_null(cum_num_in_bin);
}
