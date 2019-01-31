#include "q_incs.h"
#include "do_string.h"

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

extern lua_State *g_L_DT; 
extern char g_err[DT_ERR_MSG_LEN+1]; 

int
do_string(
    const char *const args,
    const char *const body
    )
{
  int status = 0;
  status = luaL_dostring(g_L_DT, body);
  if ( status != 0 ) { 
    fprintf(stderr, "Lua load : %s\n", lua_tostring(g_L_DT, -1));
    sprintf(g_err, "{ \"error\": \"%s\"}",lua_tostring(g_L_DT, -1));
    lua_pop(g_L_DT, 1); go_BYE(-1);
  }
  cBYE(status);
BYE:
  return status;
}
