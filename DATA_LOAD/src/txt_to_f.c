#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <float.h>
#include "q_macros.h"
#include "is_valid_chars_for_num.h"
//START_FUNC_DECL
int
txt_to_f(
      const char *X,
      float *ptr_out
      )
//STOP_FUNC_DECL
{
  int status = 0;
  char *endptr;
  double out;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  if ( !is_valid_chars_for_num(X) ) { go_BYE(-1); }
  out = strtod(X, &endptr);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  if ( ( valF8 < FLT_MIN ) || ( valF8 > FLT_MAX ) ) { go_BYE(-1); }
  *ptr_out = (float)out;
 BYE:
  return status ;
}
