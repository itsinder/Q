//START_INCLUDES
#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <string.h>
#include <fcntl.h>
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
   mcr_rs_munmap(X, nX);
   cBYE(status);  
 BYE:
   return status;
}
