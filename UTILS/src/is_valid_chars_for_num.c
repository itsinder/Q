#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdbool.h>
bool
is_valid_chars_for_num(
      const char *X
      )
{
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  for ( char *cptr = X; *cptr != '\0'; cptr++ ) { 
    if ( isdigit(*cptr) || 
        ( *cptr == '-' )  ||
        ( *cptr == '.' ) ) {
      continue;
    }
    return false;
  }
  return true;
}
