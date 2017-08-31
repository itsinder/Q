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

LUALIB_API void *luaL_testudata (lua_State *L, int ud, const char *tname);
int luaopen_libvec (lua_State *L);

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
  status = vec_eov(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_eov. ");
  return 2;
}
//----------------------------------------
static int l_vec_release_vec_buf( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int32_t num_in_chunk  = luaL_checknumber(L, 2);
  if ( num_in_chunk < 0 ) { go_BYE(-1); }
  if ( ( ptr_vec->is_nascent ) && ( ptr_vec->num_in_chunk == 0 ) ) { 
    ptr_vec->num_in_chunk += num_in_chunk;
    ptr_vec->num_elements += num_in_chunk;
    lua_pushboolean(L, true);
    return 1;
  }
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: in vec_release_vec_buf");
  return 2;
}
//----------------------------------------
static int l_vec_get_vec_buf( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( ptr_vec->is_nascent ) {
    if ( ptr_vec->num_in_chunk == ptr_vec->chunk_size ) {
      status = flush_buffer(ptr_vec); cBYE(status);
    }
    if ( ptr_vec->num_in_chunk != 0 ) { go_BYE(-1); }
    lua_pushlightuserdata(L, ptr_vec->chunk);
    /* Add the metatable to the stack. */
    luaL_getmetatable(L, "CMEM");
    /* Set the metatable on the userdata. */
    lua_setmetatable(L, -2);
    return 1;
  }
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: no chunk for materialized vector");
  return 2;
}
//----------------------------------------
static int l_vec_get( lua_State *L) {
  int status = 0;
  void *ret_addr = NULL;
  uint64_t ret_len = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t idx = luaL_checknumber(L, 2);
  int32_t len = luaL_checknumber(L, 3);
  status = vec_get(ptr_vec, idx, len, &ret_addr, &ret_len); cBYE(status);
  int num_to_return = 2;
  lua_pushlightuserdata(L, ret_addr);
  lua_pushinteger(L, ret_len);
  if ( len == 1 ) {  // this is for debugging help
    num_to_return++;
    SCLR_REC_TYPE *ptr_sclr = 
      (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
    strcpy(ptr_sclr->field_type, ptr_vec->field_type);
    ptr_sclr->field_size = ptr_vec->field_size;
    if ( strcmp(ptr_sclr->field_type, "B1") == 0 ) { 
      uint64_t word = ((uint64_t *)ret_addr)[0];
      uint32_t bit_idx = idx % 64;
      ptr_sclr->cdata.valB1 = word >> bit_idx & 0x1;
    }
    else {
      memcpy(&(ptr_sclr->cdata), ret_addr, ptr_vec->field_size);
    }
    luaL_getmetatable(L, "Scalar");
    lua_setmetatable(L, -2);
  }
  return num_to_return;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_get. ");
  return 2;
}
//------------------------------------------
static int l_vec_get_chunk( lua_State *L) 
{
  int status = 0;
  void *ret_addr = NULL;
  uint64_t ret_len = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t chunk_num = -1;
  int64_t idx;
  if  ( lua_isnumber(L, 2) ) { 
    chunk_num = luaL_checknumber(L, 2);
    if ( chunk_num < 0 ) { 
      idx = -1;
    }
    else {
      idx = chunk_num * Q_CHUNK_SIZE;
    }
  }
  else {
    if ( ptr_vec->is_nascent ) { 
      chunk_num = ptr_vec->chunk_num;
    }
    else {
      chunk_num = 0;
    }
    idx = chunk_num * Q_CHUNK_SIZE;
  }
  status = vec_get(ptr_vec, idx, Q_CHUNK_SIZE, &ret_addr, &ret_len); 
  cBYE(status);
  lua_pushlightuserdata(L, ret_addr);
  lua_pushinteger(L, ret_len);
  return 2;
BYE:
  lua_pushnil(L); lua_pushstring(L, "ERROR: vec_get. "); return 2;
}
//----------------------------------------------------
static int l_vec_put1( lua_State *L) {
  int status = 0;
  void *addr = NULL;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( !ptr_vec->is_nascent ) { go_BYE(-1); }
  if ( strcmp(ptr_vec->field_type, "SC") == 0 ) { 
    addr = luaL_checkudata(L, 2, "CMEM");
  }
  else {
    SCLR_REC_TYPE *ptr_sclr = luaL_checkudata(L, 2, "Scalar");
    if ( strcmp(ptr_vec->field_type, ptr_sclr->field_type) != 0 ) { 
      go_BYE(-1);
    }
    addr = (void *)(&ptr_sclr->cdata);
  }
  status = vec_add(ptr_vec, addr, 1); cBYE(status);
  lua_pushinteger(L, status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_put1. ");
  return 2;
}
//----------------------------------------
static int l_vec_start_write( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_start_write(ptr_vec); cBYE(status);
  lua_pushlightuserdata(L, ptr_vec->map_addr);
  lua_pushinteger(L, ptr_vec->num_elements);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_start_write. ");
  return 2;
}
//----------------------------------------
static int l_vec_end_write( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_end_write(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_end_write. ");
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
    if ( strcmp(ptr_vec->field_type, "B1") == 0 ) { 
      bool val = dtemp; memcpy(&buf, &val, 1);
    }
    else if ( strcmp(ptr_vec->field_type, "I1") == 0 ) { 
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
    // Note that SV is treated as I4
    else if ( strcmp(ptr_vec->field_type, "SV") == 0 ) { 
      int32_t val = dtemp; memcpy(&buf, &val, 4);
    }
    else {
      go_BYE(-1);
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
  void *addr = NULL;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( luaL_testudata (L, 2, "CMEM") ) { 
    addr = luaL_checkudata(L, 2, "CMEM");
  }
  else {
    fprintf(stderr, "NOT  CMEM\n");
    go_BYE(-1);
  }
  int32_t len = luaL_checknumber(L, 3);
  if ( len < 0 ) { go_BYE(-1); }
  //---------------------------------------
  status = vec_add(ptr_vec, addr, len); cBYE(status);
  lua_pushboolean(L, 1);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_put_chunk. ");
  return 2;
}
//----------------------------------------
static int l_vec_is_nascent( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_nascent);
  return 1;
}
//----------------------------------------
static int l_vec_chunk_num( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->chunk_num);
  return 1;
}
//----------------------------------------
static int l_vec_num_in_chunk( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->num_in_chunk);
  return 1;
}
//----------------------------------------
static int l_vec_num_elements( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->num_elements);
  return 1;
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
static int l_vec_new( lua_State *L) 
{
  int status = 0;
  VEC_REC_TYPE *ptr_vec = NULL;
  luaL_buffinit(L, &g_errbuf);

  //-- START: Get qtype and field size
  const char * const qtype_sz  = luaL_checkstring(L, 1);
  char qtype[4]; int field_size = 0;
  memset(qtype, '\0', 4);
  if ( strcmp(qtype_sz, "B1") == 0 ) { 
    strcpy(qtype, qtype_sz); field_size = 0; // SPECIAL CASE
  }
  else if ( strcmp(qtype_sz, "I1") == 0 ) { 
    strcpy(qtype, qtype_sz); field_size = 1;
  }
  else if ( strcmp(qtype_sz, "I2") == 0 ) { 
    strcpy(qtype, qtype_sz); field_size = 2;
  }
  else if ( strcmp(qtype_sz, "I4") == 0 ) { 
    strcpy(qtype, qtype_sz); field_size = 4;
  }
  else if ( strcmp(qtype_sz, "I8") == 0 ) { 
    strcpy(qtype, qtype_sz); field_size = 8;
  }
  else if ( strcmp(qtype_sz, "F4") == 0 ) { 
    strcpy(qtype, qtype_sz); field_size = 4;
  }
  else if ( strcmp(qtype_sz, "F8") == 0 ) { 
    strcpy(qtype, qtype_sz); field_size = 8;
  }
  else if ( strncmp(qtype_sz, "SC:", 3) == 0 ) { 
    char *cptr = (char *)qtype_sz + 3;
    status = txt_to_I4(cptr, &field_size); cBYE(status);
    if ( field_size < 2 ) { go_BYE(-1); }
    strcpy(qtype, "SC");
  }
  else if ( strcmp(qtype_sz, "SV") == 0 ) { 
    strcpy(qtype, qtype_sz); field_size = 4; // SV is stored as I4
  }
  else {
    go_BYE(-1);
  }
  //-- STOP: Get qtype and field size
  bool  is_materialized;
  bool is_memo = true;
  const char *file_name = NULL; 
  if ( lua_isstring(L, 2) ) { // filename provided for materialized vec
    file_name = luaL_checkstring(L, 2);
    is_materialized = true;
  }
  else { 
    is_materialized = false;
  }
  if ( !is_materialized ) { 
    if ( lua_isboolean(L, 3) ) { // is_memo specified
      is_memo = lua_toboolean(L, 3);
    }
  }

  int32_t chunk_size  = Q_CHUNK_SIZE; // TODO SYNC with q_consts.lua

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  status = vec_new(ptr_vec, qtype, field_size, chunk_size, is_memo); 
  cBYE(status);

  // do this after mallocing and memsetting the vector structure
  int64_t num_elements = -1;
  if ( ( strcmp(qtype, "B1") == 0 ) && ( is_materialized ) ) {
    num_elements = luaL_checknumber(L, 4);
    ptr_vec->num_elements = num_elements;
    if ( num_elements <= 0 ) { go_BYE(-1); }
  }
  if ( is_materialized ) { 
    status = vec_materialized(ptr_vec, file_name);
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
    { "put1", l_vec_put1 },
    { "persist", l_vec_persist },
    { "memo", l_vec_memo },
    { "num_elements", l_vec_num_elements },
    { "num_in_chunk", l_vec_num_in_chunk },
    { "get_chunk", l_vec_get_chunk },
    { "put_chunk", l_vec_put_chunk },
    { "get_vec_buf", l_vec_get_vec_buf },
    { "release_vec_buf", l_vec_release_vec_buf },
// TODO    { "has_nulls", l_vec_has_nulls },
    { "set", l_vec_set },
    { "get", l_vec_get },
    { "start_write", l_vec_start_write },
    { "end_write", l_vec_end_write },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "new", l_vec_new },
    { "check", l_vec_check },
    { "meta", l_vec_meta },
    { "num_elements", l_vec_num_elements },
    { "num_in_chunk", l_vec_num_in_chunk },
    { "release_vec_buf", l_vec_release_vec_buf },
    { "get_vec_buf", l_vec_get_vec_buf },
    { "put1", l_vec_put1 },
    { "persist", l_vec_persist },
    { "set", l_vec_set },
    { "get", l_vec_get },
    { "eov", l_vec_eov },
    { "chunk_num", l_vec_chunk_num },
    { "is_nascent", l_vec_is_nascent },
    { "get_chunk", l_vec_get_chunk },
    { "put_chunk", l_vec_put_chunk },
    { "start_write", l_vec_start_write },
    { "end_write", l_vec_end_write },
    { NULL,  NULL         }
};

/*
** Implementation of luaL_testudata which will return NULL in case if udata is not of type tname
** TODO: Check for the appropriate location for this function
*/
LUALIB_API void *luaL_testudata (lua_State *L, int ud, const char *tname) {
  void *p = lua_touserdata(L, ud);
  if (p != NULL) {  /* value is a userdata? */
    if (lua_getmetatable(L, ud)) {  /* does it have a metatable? */
      lua_getfield(L, LUA_REGISTRYINDEX, tname);  /* get correct metatable */
      if (lua_rawequal(L, -1, -2)) {  /* does it have the correct mt? */
        lua_pop(L, 2);  /* remove both metatables */
        return p;
      }
    }
  }
  return NULL;  /* to avoid warnings */
}
 
/*
** Open vector library
*/
int luaopen_libvec (lua_State *L) {
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
  luaL_register(L, NULL, vector_methods);

  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, vector_functions);

  return 1;
}
