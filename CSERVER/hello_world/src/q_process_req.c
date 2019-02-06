#include "q_incs.h"
#include "q_process_req.h"
#include "auxil.h"
#include "init.h"
#include "setup.h"
#include "do_string.h"
#include "do_file.h"

extern bool g_halt; 
extern char g_err[Q_ERR_MSG_LEN+1]; 
extern char g_buf[Q_ERR_MSG_LEN+1]; 
extern char g_rslt[Q_MAX_LEN_RESULT+1]; 

// START FUNC DECL
int
q_process_req(
    Q_REQ_TYPE req_type,
    const char *const api,
    char * const args,
    const char * const body
    )
  // STOP FUNC DECL
{
  int status = 0;
  //-----------------------------------------
  memset(g_rslt, '\0', Q_MAX_LEN_RESULT+1);
  memset(g_err,  '\0', Q_ERR_MSG_LEN+1);
  memset(g_buf,  '\0', Q_ERR_MSG_LEN+1);
  //-----------------------------------------
  switch ( req_type ) {
    case Undefined :
      go_BYE(-1);
      break;
      //--------------------------------------------------------
    case DoString :
      status = do_string(args, body); cBYE(status);
      break;
      //--------------------------------------------------------
    case DoFile :
      status = do_file(args, body); cBYE(status);
      break;
      //--------------------------------------------------------
    case Halt : 
      sprintf(g_rslt, "{ \"%s\" : \"OK\" }", api);
      g_halt = true;
      break;
      //--------------------------------------------------------
    case HealthCheck : 
    case Ignore :
      sprintf(g_rslt, "{ \"%s\" : \"OK\" }", api);
      break;
      //--------------------------------------------------------
    default :
      go_BYE(-1);
      break;
  }
BYE:
  return status ;
}
