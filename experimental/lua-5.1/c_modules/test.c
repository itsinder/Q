#define LUA_LIB

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "vec.h"

// TODO Move following decl
typedef struct _cmem_rec_type {
  void *addr;
  int32_t sz;
} CMEM_REC_TYPE;

//LUAMOD_API int luaopen_libtest (lua_State *L);
int luaopen_libtest (lua_State *L);

static int l_vec_eov( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int32_t is_read_only = luaL_checknumber(L, 2);
  int status = vec_eov(ptr_vec, is_read_only);
  if ( status == 0) { 
    lua_pushinteger(L, status);
    return 1;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_eov. ");
    return 2;
  }
}
//----------------------------------------
static int l_vec_get( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t idx = luaL_checknumber(L, 2);
  int32_t len = luaL_checknumber(L, 3);
  int status = vec_get(ptr_vec, idx, len);
  if ( status == 0) { 
    lua_pushlightuserdata(L, ptr_vec->ret_addr);
    lua_pushinteger(L, ptr_vec->ret_len);
    return 2;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_get. ");
    return 2;
  }
}
//----------------------------------------
//----------------------------------------
static int l_vec_set( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  CMEM_REC_TYPE *ptr_X = luaL_checkudata(L, 2, "CMEM");
  char * addr = ptr_X->addr;
  if ( ptr_X->sz != 4096 ) { 
    printf("STRANGE\n"); goto ERR; 
  }
  int64_t idx = luaL_checknumber(L, 3);
  int32_t len = luaL_checknumber(L, 4);
  int status = vec_set(ptr_vec, addr, idx, len);
  if ( status == 0) { 
    lua_pushinteger(L, status);
    return 1;
  }
ERR:
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_set. ");
    return 2;
}
//----------------------------------------
//----------------------------------------
static int l_vec_check( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_check(ptr_vec);
  if ( status == 0) { 
    lua_pushinteger(L, status);
    return 1;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_check. ");
    return 2;
  }
}
//----------------------------------------
static int l_vec_materialized( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  const char *file_name = luaL_checkstring(L, 2);
  int32_t is_read_only      = luaL_checknumber(L, 3);
  int status = vec_materialized(ptr_vec, file_name, is_read_only);
  if ( status == 0) { 
    lua_pushinteger(L, status);
    return 1;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_materialized. ");
    return 2;
  }
}
//----------------------------------------
static int l_vec_nascent( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_nascent(ptr_vec);
  if ( status == 0) { 
    lua_pushinteger(L, status);
    return 1;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_nascent. ");
    return 2;
  }
}
//----------------------------------------
static int l_vec_free( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_free(ptr_vec);
  if ( status != 0) { luaL_error(L, "could not free vector\n"); }
  return 1;
}
//----------------------------------------
static int l_vec_new( lua_State *L) {
  const char *qtype  = luaL_checkstring(L, 1);
  int32_t field_size  = luaL_checknumber(L, 2);
  int32_t chunk_size  = luaL_checknumber(L, 3);

  VEC_REC_TYPE *ptr_vec = NULL;
  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  // fprintf(stderr, "ptr_vec = %llu \n", (unsigned long long)ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  int status = vec_new(ptr_vec, qtype, field_size, chunk_size);
  if ( status != 0) { luaL_error(L, "could not create vector\n"); }
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "Vector");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
}
//-----------------------
static const struct luaL_Reg vector_methods[] = {
    { "__gc",    l_vec_free   },
    { "nascent", l_vec_nascent },
    { "materialized", l_vec_materialized },
    { "eov", l_vec_eov },
    { "check", l_vec_check },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "new", l_vec_new },
    { "nascent", l_vec_nascent },
    { "get", l_vec_get },
    { "set", l_vec_set },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/
//LUAMOD_API int luaopen_libtest (lua_State *L) {
int luaopen_libtest (lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "Vector");
  /* Duplicate the metatable on the stack (We know have 2). */
  lua_pushvalue(L, -1);
  /* Pop the first metatable off the stack and assign it to __index
   * of the second one. We set the metatable for the table to itself.
   * This is equivalent to the following in lua:
   * metatable = {}
   * metatable.__index = metatable
   */

  lua_setfield(L, -2, "__index");

  /* Register the object.func functions into the table that is at the 
   * top of the stack. */

  /* Set the methods to the metatable that should be accessed via
   * object:func */
  //luaL_setfuncs(L, vector_methods, 0);
  luaL_register(L, NULL, vector_methods);

  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  //luaL_newlib(L, vector_functions);
  luaL_register(L, NULL, vector_functions);

  return 1;
}
