#include "q_incs.h"
#include "_trim.h"
// assumption that inbuf and outbuf have been malloc'd with n bytes
// also, inbuf is null terminated and memset to 0 before being filled
//START_FUNC_DECL
int 
trim(
    char * restrict inbuf,  /* input */
    char * restrict outbuf, 
    int n /* number of bytes allocated */
    )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( inbuf == NULL ) { go_BYE(-1); }
  if ( outbuf == NULL ) { go_BYE(-1); }
  if ( n <= 1 ) { go_BYE(-1); }
  int start_idx, stop_idx;
  // START: trim lbuf into buf
  if ( inbuf[n-1] != '\0' ) { go_BYE(-1); }
  memset(outbuf, '\0', n);
  for ( start_idx = 0; start_idx < n; start_idx++ ) { 
    if ( !isspace(inbuf[start_idx]) ) { break; }
  }
  if ( start_idx >= (n-1) ) { 
    // No valid character in inbuf. outbuf has been set to nullc
    return status; 
  }
  // TODO: Following is NOT correct. Needs to be fixed
  int idx = start_idx; stop_idx = -1;
  for ( ; idx < n; idx++ ) { 
    if ( inbuf[idx] == '\0' ) { 
      if ( stop_idx < 0 ) { stop_idx = idx; }
      break; 
    }

    if ( isspace(inbuf[idx]) ) {
      if ( stop_idx < 1 ) { stop_idx = idx; }
    }
    else {
      stop_idx = -1;
    }
  }
  int k = 0;
  for ( int j = start_idx; j < stop_idx; j++, k++ ) { 
    outbuf[k] = inbuf[j];
  }
BYE:
  return status;
}
