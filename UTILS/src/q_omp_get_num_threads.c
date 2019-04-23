//START_INCLUDES
#include "q_incs.h"
#include <omp.h>
//STOP_INCLUDES
#include "_q_omp_get_num_threads.h"
//START_FUNC_DECL
int // TODO inline this function
q_omp_get_num_threads(
    void
    )
//STOP_FUNC_DECL
{
  return omp_get_num_threads();
}
