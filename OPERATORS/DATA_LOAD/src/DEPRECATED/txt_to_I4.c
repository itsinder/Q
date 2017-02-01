#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>
#include <limits.h>
#include "q_macros.h"
#include "is_valid_chars_for_num.h"
//START_FUNC_DECL
int
txt_to_I4(
      const char *X,
      int32_t *ptr_out
      )
//STOP_FUNC_DECL
{
  int status = 0;
  char *endptr;
  int64_t out;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); } 
  if ( !is_valid_chars_for_num(X) ) { go_BYE(-1); }
  out = strtoll(X, &endptr, 10);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  if ( ( out < INT_MIN ) || ( out > INT_MAX ) ) { go_BYE(-1); }
  *ptr_out = (int32_t)out;
 BYE:
  return status ;
}
