#define LUA_LIB

#include <stdlib.h>
#include <math.h>
#include <inttypes.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "_txt_to_B1.h"
#include "_txt_to_I1.h"
#include "_txt_to_I2.h"
#include "_txt_to_I4.h"
#include "_txt_to_I8.h"
#include "_txt_to_F4.h"
#include "_txt_to_F8.h"

// TODO Move following decl

#include "scalar.h"

extern int luaopen_libsclr (lua_State *L);

static int l_sclr_to_cdata( lua_State *L) {
  SCLR_REC_TYPE *ptr_sclr = NULL;

  if ( lua_gettop(L) < 1 ) { WHEREAMI; goto BYE; }
  ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( ptr_sclr == NULL ) { WHEREAMI; goto BYE; }
  lua_pushlightuserdata(L, &(ptr_sclr->cdata));
  luaL_getmetatable(L, "CMEM");
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_to_cdata. ");
  return 2;
}

static int l_sclr_to_num( lua_State *L) {

  if ( lua_gettop(L) < 1 ) { WHEREAMI; goto BYE; }
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  const char *field_type = ptr_sclr->field_type;
  if ( strcmp(field_type, "B1" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valB1);
  }
  else if ( strcmp(field_type, "I1" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valI1);
  }
  else if ( strcmp(field_type, "I2" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valI2);
  }
  else if ( strcmp(field_type, "I4" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valI4);
  }
  else if ( strcmp(field_type, "I8" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valI8);
  }
  else if ( strcmp(field_type, "F4" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valF4);
  }
  else if ( strcmp(field_type, "F8" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valF8);
  }
  else {
    WHEREAMI; goto BYE;
  }
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_to_num. ");
  return 2;
}

static int l_fldtype(lua_State *L) {
  if ( lua_gettop(L) < 1 ) { WHEREAMI; goto BYE; }
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  lua_pushstring(L, ptr_sclr->field_type);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: fldtype. ");
  return 2;
}

static int l_sclr_to_str( lua_State *L) {
#define BUFLEN 31
  char buf[BUFLEN+1];

  if ( lua_gettop(L) < 1 ) { WHEREAMI; goto BYE; }
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  // TODO Allow user to provide format
  memset(buf, '\0', BUFLEN+1);
  const char *field_type = ptr_sclr->field_type;
  if ( strcmp(field_type, "B1" ) == 0 ) { 
    if (  ptr_sclr->cdata.valB1 ) { 
      strncpy(buf, "true", BUFLEN);
    }
    else {
      strncpy(buf, "false", BUFLEN);
    }
  }
  else if ( strcmp(field_type, "I1" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI1);
  }
  else if ( strcmp(field_type, "I2" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI2);
  }
  else if ( strcmp(field_type, "I4" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI4);
  }
  else if ( strcmp(field_type, "I8" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%" PRId64, ptr_sclr->cdata.valI8);
  }
  else if ( strcmp(field_type, "F4" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%f", ptr_sclr->cdata.valF4);
  }
  else if ( strcmp(field_type, "F8" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%lf", ptr_sclr->cdata.valF8);
  }
  else {
    WHEREAMI; goto BYE;
  }
  lua_pushstring(L, buf);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_to_str. ");
  return 2;
}
static int l_sclr_new( lua_State *L) {
  int status = 0;
  bool    tempB1;
  int8_t  tempI1;
  int16_t tempI2;
  int32_t tempI4;
  int64_t tempI8;
  float   tempF4;
  double  tempF8;
  const char *str_val = NULL;
  lua_Number  in_val;
  void *in_cmem = NULL;

  // TESTING GC problems lua_gc(L, LUA_GCCOLLECT, 0);  

  if ( lua_gettop(L) < 2 ) { go_BYE(-1); }
  if ( lua_isstring(L, 1) ) { 
    str_val = luaL_checkstring(L, 1);
  }
  else if ( lua_islightuserdata(L, 1) ) { 
    // TODO P3
    go_BYE(-1);
  }
  else if ( lua_isuserdata(L, 1) ) { 
    // in_cmem = luaL_checkudata(L, 1, "CMEM");
    in_cmem = lua_touserdata(L, 1);
  }
  else if ( lua_isnumber(L, 1) ) {
    // No matter how I invoke it, Lua sends value as string
    go_BYE(-1); 
    in_val = luaL_checknumber(L, 1);
  }
  else if ( lua_isboolean(L, 1) ) {
    // However, if I invoke as true, then it comes here
    in_val = lua_toboolean(L, 1);
  }
  else {
    go_BYE(-1);
  }
  const char *qtype   = luaL_checkstring(L, 2);
  SCLR_REC_TYPE *ptr_sclr = NULL;
  ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  char *dst = (char *)&(ptr_sclr->cdata);

  if ( qtype == NULL ) { /* TODO P4 Infer qtype go_BYE(-1); */ }

  if ( strcmp(qtype, "B1" ) == 0 ) {
    if ( in_cmem != NULL ) { 
      memcpy(dst, in_cmem, 1);
    }
    else {
      if ( str_val == NULL ) { 
        tempB1 = in_val;
      }
      else {
        status = txt_to_B1(str_val, &tempB1); cBYE(status);
      }
      ptr_sclr->cdata.valB1 = tempB1;
    }
    strcpy(ptr_sclr->field_type, "B1"); 
    ptr_sclr->field_size = sizeof(bool);
  }
  else if ( strcmp(qtype, "I1" ) == 0 ) { 
    if ( in_cmem != NULL ) { 
      memcpy(dst, in_cmem, 1);
    }
    else {
      status = txt_to_I1(str_val, &tempI1); cBYE(status);
      memcpy(dst, &tempI1, 1); 
    }
    strcpy(ptr_sclr->field_type, "I1"); 
    ptr_sclr->field_size = 1;
  }
  else if ( strcmp(qtype, "I2" ) == 0 ) { 
    if ( in_cmem != NULL ) { 
      memcpy(dst, in_cmem, 2);
    }
    else {
      status = txt_to_I2(str_val, &tempI2); cBYE(status);
      memcpy(dst, &tempI2, 2); 
    }
    strcpy(ptr_sclr->field_type, "I2"); 
    ptr_sclr->field_size = 2;
  }
  else if ( strcmp(qtype, "I4" ) == 0 ) { 
    if ( in_cmem != NULL ) { 
      memcpy(dst, in_cmem, 4);
    }
    else {
      status = txt_to_I4(str_val, &tempI4); cBYE(status);
      memcpy(dst, &tempI4, 4); 
    }
    strcpy(ptr_sclr->field_type, "I4"); 
    ptr_sclr->field_size = 4;
  }
  else if ( strcmp(qtype, "I8" ) == 0 ) { 
    if ( in_cmem != NULL ) { 
      memcpy(dst, in_cmem, 8);
    }
    else {
      status = txt_to_I8(str_val, &tempI8); cBYE(status);
      memcpy(dst, &tempI8, 8); 
    }
    strcpy(ptr_sclr->field_type, "I8"); 
    ptr_sclr->field_size = 8;
  }
  else if ( strcmp(qtype, "F4" ) == 0 ) { 
    if ( in_cmem != NULL ) { 
      memcpy(dst, in_cmem, 4);
    }
    else {
      status = txt_to_F4(str_val, &tempF4); cBYE(status);
      memcpy(dst, &tempF4, 4); 
    }
    strcpy(ptr_sclr->field_type, "F4"); 
    ptr_sclr->field_size = 4;
  }
  else if ( strcmp(qtype, "F8" ) == 0 ) { 
    if ( in_cmem != NULL ) { 
      memcpy(dst, in_cmem, 8);
    }
    else {
      status = txt_to_F8(str_val, &tempF8); cBYE(status);
      memcpy(dst, &tempF8, 8); 
    }
    strcpy(ptr_sclr->field_type, "F8"); 
    ptr_sclr->field_size = 8;
  }
  else {
    go_BYE(-1);
  }
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "Scalar");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_new. ");
  return 2;
}
static int set_output_field_type(
    const char *const fldtype1,
    const char *const fldtype2,
    SCLR_REC_TYPE *ptr_sclr
    )
{
  int status = 0;
  if ( strcmp(fldtype1, "I1") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "I1");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "I2");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "I2") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "I2");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "I2");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "I4") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "I8") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "F4") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "F8") == 0 ) {
    strcpy(ptr_sclr->field_type, "F8");
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
//----------------------------------------

#include "_eval_cmp.c"
#include "_outer_eval_cmp.c"
#include "_eval_arith.c"
#include "_outer_eval_arith.c"
//-----------------------
static const struct luaL_Reg sclr_methods[] = {
    { "cdata", l_sclr_to_cdata },
    { "to_str", l_sclr_to_str },
    { "to_num", l_sclr_to_num },
    { "fldtype", l_fldtype },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg sclr_functions[] = {
    { "new", l_sclr_new },
    { "cdata", l_sclr_to_cdata },
    { "fldtype", l_fldtype },
    { "to_str", l_sclr_to_str },
    { "to_num", l_sclr_to_num },
    { "eq", l_sclr_eq },
    { "neq", l_sclr_neq },
    { "gt", l_sclr_gt },
    { "lt", l_sclr_lt },
    { "geq", l_sclr_geq },
    { "leq", l_sclr_leq },
    { "add", l_sclr_add },
    { "sub", l_sclr_sub },
    { "mul", l_sclr_mul },
    { "div", l_sclr_div },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/

int luaopen_libsclr (lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "Scalar");
  /* Duplicate the metatable on the stack (We know have 2). */
  lua_pushvalue(L, -1);
  /* Pop the first metatable off the stack and assign it to __index
   * of the second one. We set the metatable for the table to itself.
   * This is equivalent to the following in lua:
   * metatable = {}
   * metatable.__index = metatable
   */
  lua_setfield(L, -2, "__index");
  lua_pushcfunction(L, l_sclr_to_str); lua_setfield(L, -2, "__tostring");

  lua_pushcfunction(L, l_sclr_eq); lua_setfield(L, -2, "__eq");
  lua_pushcfunction(L, l_sclr_lt); lua_setfield(L, -2, "__lt");
  lua_pushcfunction(L, l_sclr_leq); lua_setfield(L, -2, "__le");
  /* negations of above happen automatically. No need to do them here */

  lua_pushcfunction(L, l_sclr_add); lua_setfield(L, -2, "__add");
  lua_pushcfunction(L, l_sclr_sub); lua_setfield(L, -2, "__sub");
  lua_pushcfunction(L, l_sclr_mul); lua_setfield(L, -2, "__mul");
  lua_pushcfunction(L, l_sclr_div); lua_setfield(L, -2, "__div");

  // Following do not work currently
  // Will not work in 5.1 as per Indrajeet
  lua_pushcfunction(L, l_sclr_to_num); lua_setfield(L, -2, "__tonumber");
  // Above do not work currently

  /* Register the object.func functions into the table that is at the 
   * top of the stack. */

  /* Set the methods to the metatable that should be accessed via
   * object:func */
  luaL_register(L, NULL, sclr_methods);

  /* Register Scalar in types table */
  int status = luaL_dostring(L, "return require 'Q/UTILS/lua/q_types'");
  if (status != 0 ) {
    fprintf(stderr, "Running require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  } 
  luaL_getmetatable(L, "Scalar");
  lua_pushstring(L, "Scalar");
  status =  lua_pcall(L, 2, 0, 0);
  if (status != 0 ) {
     fprintf(stderr, "%d\n", status);
     fprintf(stderr, "Type registration failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  /* Register the object.func functions into the table that is at the
   op of the stack. */
  
  // Registering with Q
  status = luaL_dostring(L, "return require('Q/q_export').export");
  if (status != 0 ) {
    fprintf(stderr, "Q registration require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  }
  lua_pushstring(L, "Scalar");
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, sclr_functions);
  status = lua_pcall(L, 2, 1, 0);
  if (status != 0 ){
     fprintf(stderr, "%d\n", status);
     fprintf(stderr, "q_export registration failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  // TODO: Why is return code not 0?  
  return 1;
}
