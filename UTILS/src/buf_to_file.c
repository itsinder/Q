//START_INCLUDES
#include "q_incs.h"
#include "mmap_types.h"
#include "_f_mmap.h"
//STOP_INCLUDES
#include "_buf_to_file.h"
//START_FUNC_DECL
int
buf_to_file(
   const char *addr,
   size_t size,
   size_t nmemb,
   const char * const file_name
)
//STOP_FUNC_DECL
{
  int status = 0;
  FILE *fp = NULL;

  if ( size == 0 ) { go_BYE(-1); }
  if ( nmemb == 0 ) { go_BYE(-1); }
  if ( ( file_name == NULL ) || ( *file_name == '\0' ) ) { go_BYE(1); }
  if ( addr == NULL ) { go_BYE(-1); }
  fp = fopen(file_name, "a");
  return_if_fopen_failed(fp, file_name, "wb");
  size_t nw = fwrite(addr, size, nmemb, fp);
  fclose(fp);
  if ( nw != nmemb ) { go_BYE(-1); }
BYE:
  return status;
}
