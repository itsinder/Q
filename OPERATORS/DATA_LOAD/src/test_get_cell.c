#include <stdio.h>
#include <string.h>
#include "q_macros.h"
#include "q_types.h"
#include "get_cell.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  char *X = "abc,\"de,f\",123,456\nabc,\"de\\\\f\",123,456\n";
  size_t nX = strlen(X);
  size_t xidx = 0;
  int bufsz = 32;
  char buf[bufsz]; 
  int ncols = 4;
  int rowidx = 0, colidx = 0;
  for ( ; ; ) { 
    bool is_last_col;
    if ( colidx == (ncols-1) ) { 
      is_last_col = true;
    }
    else { 
      is_last_col = false;
    }
    xidx = get_cell(X, nX, xidx, is_last_col, buf, bufsz);
    if ( xidx == 0 ) { go_BYE(-1); }
    fprintf(stderr, "%d:%d->%s\n", rowidx, colidx, buf);
    if ( is_last_col ) { 
      rowidx++;
      colidx = 0;
    }
    else {
      colidx++;
    }
    if ( xidx >= nX ) { break; }
  }
  fprintf(stderr, "Completed successfully\n");
BYE:
  return status;
}
