#include "q_incs.h"
#include "auxil.h"
#include "env_var.h"

extern char g_q_data_dir[Q_MAX_LEN_FILE_NAME+1];
extern char g_q_metadata_file[Q_MAX_LEN_FILE_NAME+1];

int
env_var(
    void
    )
{
  int status = 0;
  char *cptr;
  FILE *fp = NULL;
  //-----------------------------------------------------
  cptr = getenv("Q_DATA_DIR");
  if ( cptr == NULL ) { go_BYE(-1); }
  if ( strlen(cptr) > Q_MAX_LEN_FILE_NAME ) { go_BYE(-1); }
  if ( !isdir(cptr) ) { go_BYE(-1); }
  strncpy(g_q_data_dir, cptr, Q_MAX_LEN_FILE_NAME);
  if ( !isdir(g_q_data_dir) ) { go_BYE(-1); }
  //-----------------------------------------------------
  cptr = getenv("Q_METADATA_FILE");
  if ( cptr == NULL ) { go_BYE(-1); }
  if ( strlen(cptr) > Q_MAX_LEN_FILE_NAME ) { go_BYE(-1); }
  strncpy(g_q_metadata_file, cptr, Q_MAX_LEN_FILE_NAME);
  fp = fopen(g_q_metadata_file, "r");
  if ( fp == NULL ) { 
    fp = fopen(g_q_metadata_file, "w");

    int nw = fprintf(fp, "\n"); 
    if ( nw != 1 ) { go_BYE(-1); }
    fclose_if_non_null(fp);
  }
  fclose_if_non_null(fp);
  //-----------------------------------------------------


BYE:
  fclose_if_non_null(fp);
  return status;
}
