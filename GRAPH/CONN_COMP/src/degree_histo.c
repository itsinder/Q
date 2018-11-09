#include <stdio.h>
#include <sys/mman.h>
#include "q_incs.h"
#include "_mmap.h"
#include "_rdtsc.h"

int 
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  char *infile = NULL;
  char *opfile1 = NULL;
  char *opfile2 = NULL;
  int max_id;
  char *X = NULL; size_t nX = 0;
  int *degree = NULL;
  FILE *ofp1 = NULL;
  FILE *ofp2 = NULL;

  if ( argc != 5 ) { go_BYE(-1); }
  infile  = argv[1];
  opfile1 = argv[2];
  opfile2 = argv[3];
  if ( strcmp(infile, opfile1) == 0 ) { go_BYE(-1); }
  if ( strcmp(opfile1, opfile2) == 0 ) { go_BYE(-1); }
  max_id = atoi(argv[4]); 
  if ( max_id <= 0 ) { go_BYE(-1); }
  int nV = max_id + 1;
  degree = malloc(nV * sizeof(int));
  return_if_malloc_failed(degree);
#pragma omp parallel for
  for ( int i = 0; i < nV; i++ ) { 
    degree[i] = 0;
  }
  //-----------------------
  status = rs_mmap(infile, &X, &nX, 0); cBYE(status);
  uint64_t n = nX / sizeof(int);
  int *E = (int *)X;
  uint64_t t_start = RDTSC();
// #pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < n; i++ ) {
    int node_id = E[i];
#ifdef DEBUG
    if ( ( node_id < 0 ) || ( node_id >= max_id ) ) { 
      fprintf(stderr, "node_id = %d \n", node_id);
      go_BYE(-1);
    }
    if ( ( i % 10000000 ) == 0 ) { 
      fprintf(stderr, "Processed %lf \n", (double)i);
    }
#endif
    degree[node_id]++;
  }
  uint64_t t_stop = RDTSC();
  fprintf(stderr, "Successfully calculated degrees in time %lf\n",
      (t_stop - t_start)/(2800.0*1000000.0));
  ofp1 = fopen(opfile1, "wb");
  return_if_fopen_failed(ofp1, opfile1, "wb");

  ofp2 = fopen(opfile2, "wb");
  return_if_fopen_failed(ofp2, opfile2, "wb");

  for ( int i = 0; i < nV; i++ ) { 
    if ( degree[i] > 0 ) {
      fwrite(&i,       sizeof(int), 1,  ofp1);
      fwrite(degree+i, sizeof(int), 1,  ofp2);
    }
  }
  fprintf(stderr, "Wrote answer \n");
BYE:
  mcr_rs_munmap(X, nX);
  free_if_non_null(degree);
  fclose_if_non_null(ofp1);
  fclose_if_non_null(ofp2);
  return status;
}
