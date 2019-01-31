#include "q_incs.h"
#include "auxil.h"
#include "do_file.h"

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

extern lua_State *g_L_DT; 
extern char g_err[DT_ERR_MSG_LEN+1]; 

int
do_file(
    char *const args,
    const char *const body
    )
{
  int status = 0;
  status = luaL_dostring(g_L_DT, body);
  char *cptr = strstr(args, "File=");
  if ( cptr == NULL ) { go_BYE(-1); }
  char *file_name = args + strlen("File=");
  if ( !isfile(file_name) ) { go_BYE(-1); }

  status = luaL_dofile(g_L_DT, file_name);
  if ( status != 0 ) { 
    fprintf(stderr, "Lua load : %s\n", lua_tostring(g_L_DT, -1));
    sprintf(g_err, "{ \"error\": \"%s\"}",lua_tostring(g_L_DT, -1));
    lua_pop(g_L_DT, 1); go_BYE(-1);
  }
  cBYE(status);
BYE:
  return status;
}
