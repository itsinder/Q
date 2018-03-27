extern "C" {
//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "_cuda_malloc.h"
}

//START_FUNC_DECL
void *
cuda_malloc(
    int64_t N
    )
//STOP_FUNC_DECL
{
  // CUDA: malloc using cudaMallocManaged
  static void *ptr;
  cudaMallocManaged(&ptr, N);
  return ptr;
}
