#include <stdio.h>
#include <string.h>
#include "q_macros.h"
#include "q_types.h"

size_t
get_cell(
    char *X,
    size_t nX,
    size_t xidx,
    bool is_last_col,
    char *buf,
    size_t bufsz
    )
{
  int status = 0;
  size_t bak_xidx = xidx;
  int bufidx = 0;
  if ( X == NULL ) { go_BYE(-1); }
  if ( nX == 0 ) { go_BYE(-1); }
  if ( xidx == nX ) { go_BYE(-1); }
  if ( buf == NULL ) { go_BYE(-1); }
  if ( bufsz == 0 ) { go_BYE(-1); }
  memset(buf, '\0', bufsz);
  if ( X[xidx] == ',' ) { 
    return ++xidx; // jump over comma
  }
  bool start_dquote = false;
  if ( X[xidx] == '"' ) { // must end with dquote
    start_dquote = true;
    xidx++;
  }
  for ( ; ; ) { 
    if ( X[xidx] == '\\' ) {
      xidx++;
      if ( xidx >= nX ) { go_BYE(-1); }
      if ( bufidx >= bufsz ) { go_BYE(-1); }
      buf[bufidx++] = X[xidx];
      continue;
    }
    if ( ( start_dquote ) && ( X[xidx] == '"' ) ) {
      // consume dquote and quit
      xidx++; goto BYE;
    }
    if ( !start_dquote ) {
      if ( ( is_last_col ) && ( X[xidx] == '\n' ) ) {
        // consume comma or eoln and quit
        xidx++; goto BYE;
      }
    }
    if ( bufidx >= bufsz ) { go_BYE(-1); }
    buf[bufidx++] = X[xidx];
  }
BYE:
  if ( status < 0 ) { xidx = 0; }
  return xidx;
}
