#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "q_incs.h"
#include "init.h"
#include "auxil.h"
extern lua_State *g_L_DT; 
extern bool g_halt; 

extern char g_err[DT_ERR_MSG_LEN+1]; 
extern char g_buf[DT_ERR_MSG_LEN+1]; 
extern char g_rslt[DT_MAX_LEN_RESULT+1]; 

extern char g_valid_chars_in_url[256]; 

void
free_globals(
    void
    )
{
  if ( g_L_DT != NULL ) { lua_close(g_L_DT); g_L_DT = NULL; }
}

void
zero_globals(
    void
    )
{
  g_halt = false;
  memset(g_err, '\0', DT_ERR_MSG_LEN+1);
  memset(g_buf, '\0', DT_ERR_MSG_LEN+1);
  memset(g_rslt, '\0', DT_MAX_LEN_RESULT+1);

  //------------
  const char *str = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ=/_:";
  memset(g_valid_chars_in_url, '\0', 256);
  for ( char *cptr = (char *)str; *cptr != '\0'; cptr++ ) {
    g_valid_chars_in_url[(uint8_t)(*cptr)] = true;
  }

}

int
init_lua(
    void
    )
{
  int status = 0;
  g_L_DT = luaL_newstate(); if ( g_L_DT == NULL ) { go_BYE(-1); }
  luaL_openlibs(g_L_DT);  
  // status = luaL_dostring(g_L_DT, "require 'lua/init'"); 
  status = luaL_dostring(g_L_DT, "require 'test1'"); 
  // status = luaL_dostring(g_L_DT, "Q = require 'Q'");
  if ( status != 0 ) { 
    fprintf(stderr, "Lua load : %s\n", lua_tostring(g_L_DT, -1));
    sprintf(g_err, "{ \"error\": \"%s\"}",lua_tostring(g_L_DT, -1));
    lua_pop(g_L_DT, 1); go_BYE(-1);
  }
  cBYE(status);
BYE:
  return status;
}
