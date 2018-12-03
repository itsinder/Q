#include "q_incs.h"
#include "q_macros.h"
//STOP_INCLUDES
#include "_munmap.h"
//START_FUNC_DECL
int
rs_munmap(
	char *X,
	size_t nX
	)
//STOP_FUNC_DECL
{ 
   int status = 0;
   if ( ( X != NULL ) && ( nX != 0 ) ) {
     munmap(X, nX);
   }
   else {
     go_BYE(-1);
   }
 BYE:
   return status;
}
