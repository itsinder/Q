//START_INCLUDES
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdbool.h>
#include "q_macros.h"
//STOP_INCLUDES
#include "_is_valid_chars_for_num.h"
//START_FUNC_DECL
bool
is_valid_chars_for_num(
      const char * X
      )
//STOP_FUNC_DECL
{
  if ( ( X == NULL ) || ( *X == '\0' ) ) { WHEREAMI; return false; }
  for ( char *cptr = (char *)X; *cptr != '\0'; cptr++ ) { 
    if ( isdigit(*cptr) || 
        ( *cptr == '-' )  ||
        ( *cptr == '.' ) ) {
      continue;
    }
    return false;
  }
  return true;
}
