#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "q_macros.h"
//START_FUNC_DECL
int
txt_to_F4(
      float in,
      const char * const fmt,
      char *X,
      ssize_t nX
      )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( X == NULL ) { go_BYE(-1); }
  memset(X, '\0', nX);
  int nw = snprintf(X, nX-1, fmt, in);
  if ( nw >= nX ) { go_BYE(-1); }
 BYE:
  return status ;
}
