#define LUA_LIB

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "core_vec.h"
#include "scalar.h"
#include "_txt_to_I4.h"

// TODO Delete luaL_Buffer g_errbuf;
extern luaL_Buffer g_errbuf;

// TODO Move following decl
typedef struct _cmem_rec_type {
  void *addr;
  int32_t sz;
} CMEM_REC_TYPE;

LUAMOD_API int luaopen_libvec (lua_State *L);

static int l_vec_persist( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_persist = true;
  if ( lua_isboolean(L, 2) ) { 
    is_persist = lua_toboolean(L, 2);
  }
  //------------------------------
  int status = vec_persist(ptr_vec, is_persist);
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
static int l_vec_eov( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_read_only = 0;
  if ( lua_isboolean(L, 2) ) { 
    is_read_only = lua_toboolean(L, 2);
  }
  //------------------------------
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
static int l_vec_length( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( ptr_vec->is_nascent ) { 
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_eov. ");
    return 2;
  }
  else {
    int64_t num_elements = ptr_vec->num_elements;
    lua_pushinteger(L, num_elements);
    return 1;
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
    int *iptr = (int *)ptr_vec->ret_addr;
    lua_pushinteger(L, *iptr);
    return 3;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_get. ");
    return 2;
  }
}
//------------------------------------------
static int l_vec_append( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  SCLR_REC_TYPE *ptr_sclr = luaL_checkudata(L, 2, "Scalar");
  void * addr = (void *)(&ptr_sclr->cdata);
  status = vec_set(ptr_vec, addr, 0, 1); cBYE(status);
  lua_pushinteger(L, status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_append. ");
  return 2;
}
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
static int l_vec_meta( lua_State *L) {
  char opbuf[4096]; // TODO P3 try not to hard code bound
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");

  memset(opbuf, '\0', 4096);
  int status = vec_meta(ptr_vec, opbuf);
  if ( status == 0) { 
    lua_pushstring(L, opbuf);
    return 1;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_check. ");
    return 2;
  }
}
//----------------------------------------
static int l_vec_check( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_check(ptr_vec);
  if ( status == 0) { 
    lua_pushboolean(L, 1);
    return 1;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_check. ");
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
  luaL_buffinit(L, &g_errbuf);

  int status = 0;
  bool is_read_only = false; 
  //-- START: Get qtype and field size
  const char * const qtype_sz  = luaL_checkstring(L, 1);
  const char *qtype; int field_size;
  if ( strcmp(qtype_sz, "B1") == 0 ) { 
    qtype = qtype_sz; field_size = 1/8;
    fprintf(stderr, "TO BE IMPLEMENTED\n"); go_BYE(-1); 
  }
  else if ( strcmp(qtype_sz, "I1") == 0 ) { 
    qtype = qtype_sz; field_size = 1;
  }
  else if ( strcmp(qtype_sz, "I2") == 0 ) { 
    qtype = qtype_sz; field_size = 2;
  }
  else if ( strcmp(qtype_sz, "I4") == 0 ) { 
    qtype = qtype_sz; field_size = 4;
  }
  else if ( strcmp(qtype_sz, "I8") == 0 ) { 
    qtype = qtype_sz; field_size = 8;
  }
  else if ( strcmp(qtype_sz, "F4") == 0 ) { 
    qtype = qtype_sz; field_size = 4;
  }
  else if ( strcmp(qtype_sz, "F8") == 0 ) { 
    qtype = qtype_sz; field_size = 8;
  }
  else if ( strncmp(qtype_sz, "SC:", 3) == 0 ) { 
    char *cptr = (char *)qtype_sz + 3;
    status = txt_to_I4(cptr, &field_size); cBYE(status);
    if ( field_size < 2 ) { go_BYE(-1); }
  }
  else if ( strcmp(qtype_sz, "SV") == 0 ) { 
    fprintf(stderr, "TO BE IMPLEMENTED\n"); go_BYE(-1); 
  }
  else {
    go_BYE(-1);
  }
  //-- STOP: Get qtype and field size
  bool  is_materialized;
  const char *file_name = NULL; 
  const char *nn_file_name = NULL; 
  if ( lua_isstring(L, 2) ) { // filename provided for materialized vec
    file_name = luaL_checkstring(L, 2);
    is_materialized = true;
    if ( lua_isstring(L, 3) ) { // nn filename provided 
      nn_file_name = luaL_checkstring(L, 3);
    }
  }
  else { // function provided for nascent vec
    is_materialized = false;
    go_BYE(-1);
  }
  if ( is_materialized ) { 
    if ( lua_isboolean(L, 4) ) { // is_read_only specified
      is_read_only = lua_toboolean(L, 4);
    }
  }
    
  int32_t chunk_size  = 65536; // TODO P0 THIS SHOULD NOT BE HERE 

  VEC_REC_TYPE *ptr_vec = NULL;
  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  status = vec_new(ptr_vec, qtype, field_size, chunk_size); cBYE(status);
  if ( is_materialized ) { 
    status = vec_materialized(ptr_vec, file_name, nn_file_name, 
        is_read_only); 
    cBYE(status);
  }
  else {
    status = vec_nascent(ptr_vec); cBYE(status);
  }
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "Vector");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  luaL_pushresult(&g_errbuf);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not create vector\n");
  return 2;
}
//-----------------------
static const struct luaL_Reg vector_methods[] = {
    { "__gc",    l_vec_free   },
    { "eov", l_vec_eov },
    { "check", l_vec_check },
    { "meta", l_vec_meta },
    { "length", l_vec_length },
    { "append", l_vec_append },
    { "persist", l_vec_persist },
    { "set", l_vec_set },
    { "get", l_vec_get },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "new", l_vec_new },
    { "length", l_vec_length },
    { "check", l_vec_check },
    { "meta", l_vec_meta },
    { "append", l_vec_append },
    { "set", l_vec_set },
    { "get", l_vec_get },
    { NULL,  NULL         }
};
 
/*
** Open vector library
*/
LUAMOD_API int luaopen_libvec (lua_State *L) {
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
  luaL_setfuncs(L, vector_methods, 0);

  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  luaL_newlib(L, vector_functions);

  return 1;
}
