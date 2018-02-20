extern "C" {
//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
}
//START_FUNC_DECL
int 
cuda_malloc(
    int64_t N,
    void *ptr
    )
//STOP_FUNC_DECL 
{
  int status = 0;
  cudaMallocManaged(&ptr, N);
  return status;
}
