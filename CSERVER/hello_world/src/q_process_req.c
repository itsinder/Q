#include "q_incs.h"
#include "q_process_req.h"
#include "auxil.h"
#include "init.h"
#include "setup.h"

extern bool g_halt; 
extern char g_err[DT_ERR_MSG_LEN+1]; 
extern char g_buf[DT_ERR_MSG_LEN+1]; 
extern char g_rslt[DT_MAX_LEN_RESULT+1]; 

// START FUNC DECL
int
q_process_req(
    Q_REQ_TYPE req_type,
    const char *const api,
    const char *args,
    const char *body
    )
  // STOP FUNC DECL
{
  int status = 0;
  //-----------------------------------------
  memset(g_rslt, '\0', DT_MAX_LEN_RESULT+1);
  memset(g_err,  '\0', DT_ERR_MSG_LEN+1);
  memset(g_buf,  '\0', DT_ERR_MSG_LEN+1);
  //-----------------------------------------
  switch ( req_type ) {
    case Undefined :
      go_BYE(-1);
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
