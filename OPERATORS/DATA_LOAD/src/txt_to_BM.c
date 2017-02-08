#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include "q_macros.h"
#include "is_valid_chars_for_num.h"
//START_FUNC_DECL
int
txt_to_BM(
      char * const X, /* array of charactes which need to be 0 or 1 */
      uint64_t *ptr_out
      )
//STOP_FUNC_DECL
{
  int status = 0;
  uint64_t out = 0;
  for ( int i = 0; i < sizeof(uint64_t) * 
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
