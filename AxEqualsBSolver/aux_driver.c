#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>
#include "macros.h"
#include "matrix_helpers.h"
#include "aux_driver.h"

extern void
print_input(
            double **A,
            double *x,
            double *b,
            int n
            )
{
  for ( int i = 0; i < n; i++ ) {
    fprintf(stderr, "[ ");
    for ( int j = 0; j < n; j++ ) {
      if ( j == 0 ) {
        fprintf(stderr, " %2d ", (int)index_symm_matrix(A, i, j));
      }
      else {
        fprintf(stderr, ", %2d ", (int)index_symm_matrix(A, i, j));
      }
    }
    fprintf(stderr, "] ");
    // print x
    fprintf(stderr, " [ ");
    fprintf(stderr, " %2d ", (int)x[i]);
    fprintf(stderr, "] ");
    // print b
    fprintf(stderr, "  = [ ");
    fprintf(stderr, " %3d ", (int)b[i]);
    fprintf(stderr, "] ");

    fprintf(stderr, "\n");
  }
}

/* assembly code to read the TSC */
uint64_t
RDTSC(void)
{
  unsigned int hi, lo;
  __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}
