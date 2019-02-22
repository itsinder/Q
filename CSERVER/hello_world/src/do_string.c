#include "q_incs.h"
#include "do_string.h"

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

extern lua_State *g_L_Q; 

int
do_string(
    const char *const args,
    const char *const body
    )
{
  int status = 0;
  status = luaL_dostring(g_L_Q, body);
  mcr_chk_lua_rslt(status);
BYE:
  return status;
}
