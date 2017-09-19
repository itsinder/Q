#define LUA_LIB

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#define Q_CHUNK_SIZE 65536 //  TODO P1 
// Above should not be needed. Should come from q_constants.h
#include "q_incs.h"
#include "core_vec.h"
#include "scalar.h"
#include "_txt_to_I4.h"

// TODO Delete luaL_Buffer g_errbuf;
extern luaL_Buffer g_errbuf;

LUAMOD_API int luaopen_libvec (lua_State *L);

static int l_vec_memo( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_memo = true;
  if ( lua_isboolean(L, 2) ) { 
    is_memo = lua_toboolean(L, 2);
  }
  //------------------------------
  status = vec_memo(ptr_vec, is_memo); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_memo. ");
  return 2;
}
//----------------------------------------
static int l_vec_persist( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_persist = true;
  if ( lua_isboolean(L, 2) ) { 
    is_persist = lua_toboolean(L, 2);
  }
  //------------------------------
  status = vec_persist(ptr_vec, is_persist); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_memo. ");
  return 2;
}
//----------------------------------------
static int l_vec_eov( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_read_only = false;
  if ( lua_isboolean(L, 2) ) { 
    is_read_only = lua_toboolean(L, 2);
  }
  //------------------------------
  status = vec_eov(ptr_vec, is_read_only); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_eov. ");
  return 2;
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
    int num_to_return = 2;
    lua_pushlightuserdata(L, ptr_vec->ret_addr);
    lua_pushinteger(L, ptr_vec->ret_len);
    if ( len == 1 ) {  // this is for debugging help
      num_to_return++;
      SCLR_REC_TYPE *ptr_sclr = 
        (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
      strcpy(ptr_sclr->field_type, ptr_vec->field_type);
      ptr_sclr->field_size = ptr_vec->field_size;
      memcpy(&(ptr_sclr->cdata), ptr_vec->ret_addr, ptr_vec->field_size);
      luaL_getmetatable(L, "Scalar");
      lua_setmetatable(L, -2);
    }
    return num_to_return;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: vec_get. ");
    return 2;
  }
}
//------------------------------------------
static int l_vec_get_chunk( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t chunk_num = luaL_checknumber(L, 2);
  uint64_t idx = chunk_num * Q_CHUNK_SIZE;
  status = vec_get(ptr_vec, idx, Q_CHUNK_SIZE); cBYE(status);
  lua_pushlightuserdata(L, ptr_vec->ret_addr);
  lua_pushinteger(L, ptr_vec->ret_len);
  return 2;
BYE:
  lua_pushnil(L); lua_pushstring(L, "ERROR: vec_get. "); return 2;
}
//----------------------------------------------------
static int l_vec_append( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  SCLR_REC_TYPE *ptr_sclr = luaL_checkudata(L, 2, "Scalar");
  if ( !ptr_vec->is_nascent ) { go_BYE(-1); }
  if ( strcmp(ptr_vec->field_type, ptr_sclr->field_type) != 0 ) { 
    go_BYE(-1);
  }
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
  int status = 0;
  char *addr;
  int64_t idx;
  int32_t len;
  double buf; // need this to be word aligned
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  idx = luaL_checknumber(L, 3);
  if (  luaL_testudata(L, 2, "CMEM") ) { 
    void *X = luaL_checkudata(L, 2, "CMEM");
    addr = X;
    len = luaL_checknumber(L, 4);
  }
  else if (  luaL_testudata(L, 2, "Scalar") ) { 
    SCLR_REC_TYPE *ptr_sclr = luaL_checkudata(L, 2, "Scalar");
    addr = (char *)&(ptr_sclr->cdata);
    len = 1;
  }
  else if (  lua_isnumber(L, 2) ) {
    double dtemp = luaL_checknumber(L, 2);
    if ( strcmp(ptr_vec->field_type, "I1") == 0 ) { 
      int8_t val = dtemp; memcpy(&buf, &val, 1);
    }
    else if ( strcmp(ptr_vec->field_type, "I2") == 0 ) { 
      int16_t val = dtemp; memcpy(&buf, &val, 2);
    }
    else if ( strcmp(ptr_vec->field_type, "I4") == 0 ) { 
      int32_t val = dtemp; memcpy(&buf, &val, 4);
    }
    else if ( strcmp(ptr_vec->field_type, "I8") == 0 ) { 
      int64_t val = dtemp; memcpy(&buf, &val, 8);
    }
    else if ( strcmp(ptr_vec->field_type, "F4") == 0 ) { 
      float val = dtemp; memcpy(&buf, &val, 4);
    }
    else if ( strcmp(ptr_vec->field_type, "F8") == 0 ) { 
      double val = dtemp; memcpy(&buf, &val, 8);
    }
    addr = (char *)&buf;
    len = 1;
  }
  else {
    go_BYE(-1);
  }
  status = vec_set(ptr_vec, addr, idx, len); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_set. ");
  return 2;
}
//----------------------------------------
static int l_vec_put_chunk( lua_State *L) {
  int status = 0;
  // Modify idx and sent to l_vec_set
  int64_t chunk_num = luaL_checknumber(L, 3);
  if ( chunk_num < 0 ) { go_BYE(-1); }
  int64_t idx = chunk_num * Q_CHUNK_SIZE;
  lua_pushnumber(L, idx);
  lua_replace(L, 3);
  // If L, 4 is undefined or is defined and is 0, change to chunk_size
  int32_t len;
  if ( lua_isnumber(L, 4) ) { 
    len = luaL_checknumber(L, 4);
    if ( len > Q_CHUNK_SIZE ) { go_BYE(-1); }
    if ( len == 0 ) { 
      lua_pushnumber(L, Q_CHUNK_SIZE);
      lua_replace(L, 4);
    }
  }
  else {
    lua_pushnumber(L, Q_CHUNK_SIZE);
  }
  //---------------------------------------
  return l_vec_set(L);
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_push_chunk. ");
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
  else { 
    is_materialized = false;
  }
  if ( is_materialized ) { 
    if ( lua_isboolean(L, 4) ) { // is_read_only specified
      is_read_only = lua_toboolean(L, 4);
    }
  }
    
  int32_t chunk_size  = Q_CHUNK_SIZE; // TODO P0 THIS SHOULD NOT BE HERE 

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
    { "memo", l_vec_memo },
    { "get_chunk", l_vec_get_chunk },
    { "put_chunk", l_vec_put_chunk },
// TODO    { "has_nulls", l_vec_has_nulls },
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