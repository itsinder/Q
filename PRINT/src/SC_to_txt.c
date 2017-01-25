#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "q_macros.h"
//START_FUNC_DECL
int
txt_to_SC(
    char * const in,
    char * X,
    ssize_t nX
    )
//STOP_FUNC_DECL
{
  int status = 0;
  int sz = 0;
  memset(X, '\0', nX);
  if ( in == NULL ) { go_BYE(-1); }
  for ( char *cptr = in; *cptr != '\0'; cptr++ ) { 
    if ( ( *cptr == '"' ) || 
        ( *cptr == ',' ) || 
        ( *cptr == '\n' ) || 
        ( *cptr == '\\' ) ) {
      if ( sz >= nX-1 ) { go_BYE(-1); } X[sz++] = '\\';
    }
    if ( sz >= nX-1 ) { go_BYE(-1); } X[sz++] = *cptr;
  }
BYE:
  return status ;
}
