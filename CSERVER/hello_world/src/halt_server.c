#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "q_incs.h"
#include "halt_server.h"

extern lua_State *g_L_Q; 
extern char g_err[Q_ERR_MSG_LEN+1]; 

void halt_server(
    int sig
    )
{
  int status = luaL_dostring(g_L_Q, "Q.save()");
  if ( status != 0 ) {  
    fprintf(stderr, "Lua load : %s\n", lua_tostring(g_L_Q, -1)); 
    sprintf(g_err, "{ \"error\": \"%s\"}",lua_tostring(g_L_Q, -1)); 
    lua_pop(g_L_Q, 1); WHEREAMI;
  } 
}
