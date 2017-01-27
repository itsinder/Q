#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include "q_macros.h"
#include "is_valid_chars_for_num.h"
//START_FUNC_DECL
int
txt_to_SC(
      char * const X,
      char *out,
      ssize_t sz_out /* size of buffer. needs to end with nullc */
      )
//STOP_FUNC_DECL
{
  int status = 0;
  int sz = 0;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  for ( char *cptr = X; *cptr != '\0'; cptr++ ) { 
    if ( *cptr == '\\' ) { 
      if ( ( *cptr == '"' ) || 
          ( *cptr == ',' ) || 
          ( *cptr == '\n' ) || 
          ( *cptr == '\\' ) ) {
        cptr++; // skip over backslash
      }
      else {
        go_BYE(-1);
      }
    }
    if ( sz < sz_out-1 ) {
      out[sz++] = *cptr;
    }
    else {
      go_BYE(-1); 
    }
  }
  out[sz] = '\0';
BYE:
  return status ;
}