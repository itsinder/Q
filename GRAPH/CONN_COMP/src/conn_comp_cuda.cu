extern "C" {
#include "q_incs.h"
#include "_mmap.h"
}


#define NODE_TYPE int32_t
#define MAXLINE 65535

__global__
static void
any_change(
    NODE_TYPE *lb,
    NODE_TYPE *ub,
    NODE_TYPE *to,
    NODE_TYPE *lbl,
    uint64_t n_nodes,
    bool *is_any_change
    )
{
  uint64_t index = blockIdx.x * blockDim.x + threadIdx.x;
  uint64_t stride = blockDim.x * gridDim.x;
  for (uint64_t i = index; i < n_nodes; i += stride) {
    bool l_is_any_change = false;
    if ( ub[i] <= lb[i] ) { continue; }
    NODE_TYPE minval = lbl[i];
    for ( int64_t j = lb[i]; j < ub[i]; j++ ) {
      minval = mcr_min(minval, lbl[to[j]]);
    }
    if ( lbl[i] != minval ) {
      l_is_any_change = true;
      lbl[i] = minval;
    }

    if ( ( l_is_any_change ) && ( *is_any_change == false ) ) {
      *is_any_change = true;
    }

  }
}


int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  FILE *lbfp = NULL;
  FILE *ubfp = NULL;
  FILE *tofp = NULL;
  NODE_TYPE *lbl = NULL;
  NODE_TYPE *lb = NULL;
  NODE_TYPE *ub = NULL;
  NODE_TYPE *to = NULL;
  char *lb_X = NULL; size_t lb_nX = 0;
  char *ub_X = NULL; size_t ub_nX = 0;
  char *to_X = NULL; size_t to_nX = 0;

  if ( argc != 1 ) { status = -1; return status; }

  status = rs_mmap("lb.bin", &lb_X, &lb_nX, 0);
  lb = (NODE_TYPE *)lb_X;

  status = rs_mmap("ub.bin", &ub_X, &ub_nX, 0);
  ub = (NODE_TYPE *)ub_X;

  status = rs_mmap("to.bin", &to_X, &to_nX, 0);
  to = (NODE_TYPE *)to_X;

  uint64_t n_nodes = lb_nX / sizeof(NODE_TYPE);
  fprintf(stderr, "Working on  %ld nodes \n", n_nodes);

  // lbl = (NODE_TYPE *)malloc(n_nodes * sizeof(NODE_TYPE));
  cudaMallocManaged(&lbl, n_nodes * sizeof(NODE_TYPE));
  // return_if_malloc_failed(lbl);
  if ( lbl == NULL ) { return -1; }
  for ( unsigned int i = 0; i < n_nodes; i++ ) {
    lbl[i] = i;
  }

  uint64_t blockSize = 256;
  uint64_t numBlocks = (n_nodes + 256 - 1) / blockSize;

  bool is_any_change = true; // just to get in the first tome
  for ( int iter = 0; is_any_change == true; iter++ ) {
    // any_change(lb, ub, to, lbl, n_nodes, &is_any_change);
    any_change<<<numBlocks, blockSize>>>(lb, ub, to, lbl, n_nodes, &is_any_change);
    cudaDeviceSynchronize();

/*
#pragma omp parallel for schedule(static)
    for ( uint64_t i = 0; i < n_nodes; i++ ) {
      bool l_is_any_change = false;
      if ( ub[i] <= lb[i] ) { continue; }
      NODE_TYPE minval = lbl[i];
      for ( int64_t j = lb[i]; j < ub[i]; j++ ) {
        minval = mcr_min(minval, lbl[to[j]]);
      }
      if ( lbl[i] != minval ) {
        l_is_any_change = true;
        lbl[i] = minval;
      }
      if ( ( l_is_any_change ) && ( is_any_change == false ) ) {
        is_any_change = true;
      }
    }
*/
    fprintf(stderr, "Pass %d \n", iter);
  }
  cudaFree(lbl);
  return status;

//BYE:
  /*
  if ( lb_X != NULL ) { munmap(lb_X, lb_nX); }
  if ( ub_X != NULL ) { munmap(ub_X, lb_nX); }
  if ( to_X != NULL ) { munmap(to_X, lb_nX); }
  fclose_if_non_null(lbfp);
  fclose_if_non_null(ubfp);
  fclose_if_non_null(tofp);
  */
  //cudaFree(lbl);
  //return status;
}

