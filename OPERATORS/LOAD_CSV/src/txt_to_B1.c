#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "q_macros.h"
#include "_txt_to_B1.h"
//START_FUNC_DECL
int
txt_to_B1(
      const char * const X,
      bool *ptr_val
      )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  if ( ( strcmp(X, "true") == 0 ) || ( strcmp(X, "1") == 0 ) ) { 
    *ptr_val = true;
  }
  else {
    *ptr_val = false;
  }
BYE:
  return status;
}
