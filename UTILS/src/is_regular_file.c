//START_INCLUDES
#include <stdio.h>
#include <stdbool.h>
#include <fcntl.h>
#include <sys/stat.h>
//STOP_INCLUDES
#include "_is_regular_file.h"

//START_FUNC_DECL
bool 
is_regular_file (
    const char * const filename
    )
//STOP_FUNC_DECL
{
  struct stat buf;
  if ( ( filename == NULL ) || ( *filename == '\0' ) ) { return false; }
  int status = stat(filename, &buf );
  if ( status == 0 && S_ISREG( buf.st_mode ) ) { /* Path found, check for regular file */
    return true;
  }
  else {
    return false;
  }
}

