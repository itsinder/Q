#include "q_incs.h"
#include "auxil.h"
#include "env_var.h"

extern char g_q_data_dir[Q_MAX_LEN_FILE_NAME+1];
extern char g_q_metadata_file[Q_MAX_LEN_FILE_NAME+1];
extern char g_qc_flags[Q_MAX_LEN_FLAGS+1];
extern char g_link_flags[Q_MAX_LEN_FLAGS+1];

static int get_flags(
    const char *const label,
    char *X,
    size_t nX
    )
{
  int status = 0;
  if ( ( label == NULL ) || ( *label == '\0' ) ) { go_BYE(-1); }
  if ( X == NULL ) { go_BYE(-1); }
  if ( nX <= 2 ) { go_BYE(-1); }
  char *cptr = getenv(label);
  if ( cptr == NULL ) { go_BYE(-1); }
  if ( strlen(cptr) > nX ) { go_BYE(-1); }
  if ( *cptr == '\0' ) { go_BYE(-1); }
  for ( char *xptr = cptr; *xptr != '\0'; xptr++ ) {
    if ( ( isalnum(*xptr) )  || ( *xptr == '-' ) ) {
      /* all is well */
    }
    else {
      go_BYE(-1);
    }
  }
  strncpy(X, cptr, nX);
BYE:
  return status;
}
  //-----------------------------------------------------
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
  status = get_flags("QC_FLAGS", g_qc_flags, Q_MAX_LEN_FLAGS); cBYE(status);
  status = get_flags("Q_LINK_FLAGS", g_link_flags, Q_MAX_LEN_FLAGS); cBYE(status);
BYE:
  fclose_if_non_null(fp);
  return status;
}
