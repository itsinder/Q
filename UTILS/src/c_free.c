//START_INCLUDES
#include <stdlib.h>
//STOP_INCLUDES
#include "_c_free.h"

//START_FUNC_DECL
void
q_free(
    void *X
)
//STOP_FUNC_DECL
{
  if ( X != NULL ) { free(X); }
}
