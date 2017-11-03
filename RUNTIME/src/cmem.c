#define LUA_LIB

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"

#include "_B1_to_txt.h"
#include "_I1_to_txt.h"
#include "_I2_to_txt.h"
#include "_I4_to_txt.h"
#include "_I8_to_txt.h"
#include "_F4_to_txt.h"
#include "_F8_to_txt.h"

int luaopen_libcmem (lua_State *L);

static int l_cmem_malloc( lua_State *L) 
{
  int32_t sz = luaL_checknumber(L, 1);
  if ( sz <= 0 ) { goto ERR; }
  lua_newuserdata(L, sz);
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "CMEM");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
ERR:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: malloc. ");
  return 2;
}
// Following only for debugging 
static int l_cmem_seq( lua_State *L) {
#define BUFLEN 31
  char buf[BUFLEN+1]; 
  void  *X          = luaL_checkudata( L, 1, "CMEM");
  lua_Number start  = luaL_checknumber(L, 2);
  lua_Number incr   = luaL_checknumber(L, 3);
  lua_Number num    = luaL_checknumber(L, 4);
  const char *qtype = luaL_checkstring(L, 5);
  memset(buf, '\0', BUFLEN);
  if ( strcmp(qtype, "I1") == 0 ) { 
    int8_t *ptr = (int8_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I2") == 0 ) { 
    int16_t *ptr = (int16_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I4") == 0 ) { 
    int32_t *ptr = (int32_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I8") == 0 ) { 
    int64_t *ptr = (int64_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "F4") == 0 ) { 
    float *ptr = (float *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "F8") == 0 ) { 
    double *ptr = (double *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else {
    WHEREAMI; goto BYE;
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: tostring. ");
  return 2;
}
// Following only for debugging 
static int l_cmem_set( lua_State *L) {
#define BUFLEN 31
  char buf[BUFLEN+1]; 
  void  *X          = luaL_checkudata( L, 1, "CMEM");
  lua_Number val    = luaL_checknumber(L, 2);
  const char *qtype = luaL_checkstring(L, 3);
  memset(buf, '\0', BUFLEN);
  if ( strcmp(qtype, "I1") == 0 ) { 
    int8_t *ptr = (int8_t *)X; ptr[0] = val;
  }
  else if ( strcmp(qtype, "I2") == 0 ) { 
    int16_t *ptr = (int16_t *)X; ptr[0] = val;
  }
  else if ( strcmp(qtype, "I4") == 0 ) { 
    int32_t *ptr = (int32_t *)X; ptr[0] = val;
  }
  else if ( strcmp(qtype, "I8") == 0 ) { 
    int64_t *ptr = (int64_t *)X; ptr[0] = val;
  }
  else if ( strcmp(qtype, "F4") == 0 ) { 
    float *ptr = (float *)X; ptr[0] = val;
  }
  else if ( strcmp(qtype, "F8") == 0 ) { 
    double *ptr = (double *)X; ptr[0] = val;
  }
  else {
    WHEREAMI; goto BYE;
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: tostring. ");
  return 2;
}
// Following only for debugging 
static int l_cmem_to_str( lua_State *L) {
  int status = 0;
#define BUFLEN 31
  char buf[BUFLEN+1]; 
  void  *X          = luaL_checkudata( L, 1, "CMEM");
  const char *qtype = luaL_checkstring(L, 2);
  memset(buf, '\0', BUFLEN);
  if ( strcmp(qtype, "B1") == 0 ) { 
    status = B1_to_txt(X, buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "I1") == 0 ) { 
    status = I1_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "I2") == 0 ) { 
    status = I2_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "I4") == 0 ) { 
    status = I4_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "I8") == 0 ) { 
    status = I8_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "F4") == 0 ) { 
    status = F4_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "F8") == 0 ) { 
    status = F8_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else {
    go_BYE(-1);
  }
  lua_pushstring(L, buf);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: tostring. ");
  return 2;
}
//----------------------------------------
static const struct luaL_Reg cmem_methods[] = {
    { "set",          l_cmem_set               },
    { "seq",          l_cmem_seq               },
    { "to_str",        l_cmem_to_str },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg cmem_functions[] = {
    { "new", l_cmem_malloc },
    { "to_str",        l_cmem_to_str },
    { "set",          l_cmem_set               },
    { "seq",          l_cmem_seq               },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/
int luaopen_libcmem (lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "CMEM");
  /* Duplicate the metatable on the stack (We know have 2). */
  lua_pushvalue(L, -1);
  /* Pop the first metatable off the stack and assign it to __index
   * of the second one. We set the metatable for the table to itself.
   * This is equivalent to the following in lua:
   * metatable = {}
   * metatable.__index = metatable
   */
  lua_setfield(L, -2, "__index");
  lua_pushcfunction(L, l_cmem_to_str); lua_setfield(L, -2, "__tostring");

  /* Register the object.func functions into the table that is at the 
   * top of the stack. */

  /* Set the methods to the metatable that should be accessed via
   * object:func */
  luaL_register(L, NULL, cmem_methods);

  /* Register CMEM in types table */
  int status = luaL_dostring(L, "return require 'Q/UTILS/lua/q_types'");
  if (status != 0 ) {
    printf("Running require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  } 
  luaL_getmetatable(L, "CMEM");
  lua_pushstring(L, "CMEM");
  status =  lua_pcall(L, 2, 0, 0);
  if (status != 0 ){
     printf("%d\n", status);
     printf("Registering type failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  /* Register the object.func functions into the table that is at the
   op of the stack. */
  
  // Registering with Q
  status = luaL_dostring(L, "return require('Q/q_export').export");
  if (status != 0 ) {
    printf("Running Q registeration require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  }
  lua_pushstring(L, "CMEM");
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, cmem_functions);
  status = lua_pcall(L, 2, 1, 0);
  if (status != 0 ){
     printf("%d\n", status);
     printf("Registering with q_export failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  
  return 1;
}
#ifdef OLD
  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, cmem_functions);

  return 1;
#endif
