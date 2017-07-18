#define LUA_LIB

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"

typedef struct _cmem_rec_type {
  void *addr;
  int32_t sz;
} CMEM_REC_TYPE;

//LUAMOD_API int luaopen_libcmem (lua_State *L);
int luaopen_libcmem (lua_State *L);

static int l_cmem_malloc( lua_State *L) 
{
  int32_t sz = luaL_checknumber(L, 1);
  if ( sz <= 0 ) { goto ERR; }
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sz);
  ptr_cmem->addr = NULL; 
  ptr_cmem->sz   = 0; 

  void *X = malloc(sz);
  if ( X == NULL ) { goto ERR; }
  fprintf(stderr, "CMEM: Malloc %d bytes at %llu \n", sz, (uint64_t)X);
  ptr_cmem->addr = X;
  ptr_cmem->sz = sz;
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
//----------------------------------------
static int l_cmem_free( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  printf("CMEM: Freeing %d bytes  at %llu\n", ptr_cmem->sz, (uint64_t)ptr_cmem->addr);
  if ( ptr_cmem->sz <= 0  ) { goto ERR; }
  free(ptr_cmem->addr);
  lua_pushinteger(L, 0);
  return 1;
ERR:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: malloc. ");
  return 2;
}
//----------------------------------------
//----------------------------------------
static const struct luaL_Reg cmem_methods[] = {
//    { "__gc",    l_cmem_free   },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg cmem_functions[] = {
    { "new", l_cmem_malloc },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/
//LUAMOD_API int luaopen_libcmem (lua_State *L) {
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

   /* set its __gc field  */
  lua_pushstring(L, "__gc");
  lua_pushcfunction(L, l_cmem_free);
  lua_settable(L, -3);

  /* Register the object.func functions into the table that is at the 
   * top of the stack. */

  /* Set the methods to the metatable that should be accessed via
   * object:func */
  //luaL_setfuncs(L, cmem_methods, 0);

  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  //luaL_newlib(L, cmem_functions);
  luaL_register(L, NULL, cmem_functions);

  return 1;
}
