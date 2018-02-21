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

#include "cmem.h"

int luaopen_libcmem (lua_State *L);

int cmem_dupe( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    void *data,
    int64_t size,
    const char *field_type,
    const char *cell_name
    )
{
  int status = 0;
  if ( data == NULL ) { go_BYE(-1); }
  if ( size < 1 ) { go_BYE(-1); }
  ptr_cmem->data = data;
  ptr_cmem->size = size;
  if ( ( field_type != NULL ) && ( *field_type != '\0' ) ) { 
    strncpy(ptr_cmem->field_type, field_type, 4-1); // TODO Undo hard code
  }
  if ( ( cell_name != NULL ) && ( *cell_name != '\0' ) ) { 
    strncpy(ptr_cmem->cell_name, cell_name, 16-1); // TODO Undo hard code
  }
  ptr_cmem->is_foreign = true;
BYE:
  return status;
}

int cmem_malloc( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    int64_t size,
    const char *field_type,
    const char *cell_name
    )
{
  int status = 0;
  void *data = NULL;
  if ( size <= 0 ) { go_BYE(-1); }
  if ( ( ( size / 16 ) * 16 ) != size ) { 
    size = ( size / 16 ) + 16;
  }
  data = malloc(size);
  return_if_malloc_failed(data);
  ptr_cmem->data = data;
  ptr_cmem->size = size;
  if ( field_type != NULL ) { 
    strncpy(ptr_cmem->field_type, field_type, 4-1); // TODO Undo hard code
  }
  if ( cell_name != NULL ) { 
    strncpy(ptr_cmem->cell_name, cell_name, 16-1); // TODO Undo hard code
  }
  ptr_cmem->is_foreign = false;
BYE:
  return status;
}

static int l_cmem_dupe( lua_State *L) 
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  char *field_type = NULL;
  char *cell_name = NULL;
  void *data = NULL;

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));

  if ( lua_islightuserdata(L, 1) ) {
    data = lua_touserdata(L, 1);
  }
  else {
    go_BYE(-1);
  }
  int64_t size =  luaL_checknumber(L, 2);
  if ( size <= 0 ) { go_BYE(-1); }

  if ( lua_gettop(L) > 3 ) { 
    if ( lua_isstring(L, 3) ) {
      field_type = (char *)luaL_checkstring(L, 3);
    }
  }
  if ( lua_gettop(L) > 4 ) { 
    if ( lua_isstring(L, 4) ) {
      cell_name = (char *)luaL_checkstring(L, 4);
    }
  }
  status = cmem_dupe(ptr_cmem, data, size, field_type, cell_name);
  cBYE(status);

  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "CMEM");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not dupe cmem\n");
  return 2;
}
static int l_cmem_new( lua_State *L) 
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  char *field_type = NULL;
  char *cell_name = NULL;

  int64_t size =  luaL_checknumber(L, 1);
  if ( size <= 0 ) { go_BYE(-1); }

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));

  if ( lua_gettop(L) > 2 ) { 
    if ( lua_isstring(L, 2) ) {
      field_type = (char *)luaL_checkstring(L, 2);
    }
  }
  if ( lua_gettop(L) > 3 ) { 
    if ( lua_isstring(L, 3) ) {
      cell_name = (char *)luaL_checkstring(L, 3);
    }
  }

  status = cmem_malloc(ptr_cmem, size, field_type, cell_name);
  cBYE(status);

  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "CMEM");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not create cmem\n");
  return 2;
}

static int l_cmem_name( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushstring(L, ptr_cmem->cell_name);
  return 1;
}

static int l_cmem_fldtype( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushstring(L, ptr_cmem->field_type);
  return 1;
}

static int l_cmem_data( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushlightuserdata(L, ptr_cmem->data);
  return 1;
}


static int l_cmem_size( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushnumber(L, ptr_cmem->size);
  return 1;
}

static int l_cmem_is_foreign( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushboolean(L, ptr_cmem->is_foreign);
  return 1;
}
static int l_cmem_free( lua_State *L) 
{
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 1, "CMEM");
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; goto BYE; }
  if ( !ptr_cmem->is_foreign ) { 
    if ( ptr_cmem->data == NULL ) { WHEREAMI; goto BYE; }
    free(ptr_cmem->data);
  }
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: malloc failed. ");
  return 2;
}
// Following only for debugging 
static int l_cmem_seq( lua_State *L) {
#define BUFLEN 31
  char buf[BUFLEN+1]; 
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata( L, 1, "CMEM");
  lua_Number start  = luaL_checknumber(L, 2);
  lua_Number incr   = luaL_checknumber(L, 3);
  lua_Number num    = luaL_checknumber(L, 4);
  const char *qtype = luaL_checkstring(L, 5);
  void *X = ptr_cmem->data;
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
// Following only for debugging and hence has limited usage 
static int l_cmem_set( lua_State *L) {
  
  CMEM_REC_TYPE *ptr_cmem  = luaL_checkudata( L, 1, "CMEM");
  lua_Number val    = luaL_checknumber(L, 2);
  void *X = ptr_cmem->data;
  char *field_type = ptr_cmem->field_type;
  if ( lua_gettop(L) >= 3 ) { 
    if ( lua_isstring(L, 3) ) {
      field_type = (char *)luaL_checkstring(L, 3);
      if ( strcmp(field_type,  ptr_cmem->field_type) != 0 ) {
        WHEREAMI; goto BYE;
      }
    }
  }
  if ( ( field_type == NULL ) || ( *field_type == '\0' ) ) { 
    WHEREAMI; goto BYE;
  }
  if ( strcmp(field_type, "I1") == 0 ) { 
    int8_t *ptr = (int8_t *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "I2") == 0 ) { 
    int16_t *ptr = (int16_t *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "I4") == 0 ) { 
    int32_t *ptr = (int32_t *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "I8") == 0 ) { 
    int64_t *ptr = (int64_t *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "F4") == 0 ) { 
    float *ptr = (float *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "F8") == 0 ) { 
    double *ptr = (double *)X; ptr[0] = val;
  }
  else {
    WHEREAMI; goto BYE;
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: cmem:set. ");
  return 2;
}
// Following only for debugging 
static int l_cmem_to_str( lua_State *L) {
  int status = 0;
#define BUFLEN 31
  char buf[BUFLEN+1]; 
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata( L, 1, "CMEM");
  const char *qtype = luaL_checkstring(L, 2);
  memset(buf, '\0', BUFLEN);
  void  *X          = ptr_cmem->data;
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
    { "__gc",          l_cmem_free               },
    { "set",          l_cmem_set               },
    { "seq",          l_cmem_seq               },
    { "to_str",        l_cmem_to_str },
    { "fldtype",     l_cmem_fldtype },
    { "data",     l_cmem_data },
    { "size",     l_cmem_size },
    { "is_foreign",     l_cmem_is_foreign },
    { "dupe",     l_cmem_dupe },
    { "name",     l_cmem_name },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg cmem_functions[] = {
    { "new", l_cmem_new },
    { "to_str",        l_cmem_to_str },
    { "fldtype",     l_cmem_fldtype },
    { "data",     l_cmem_data },
    { "size",     l_cmem_size },
    { "is_foreign",     l_cmem_is_foreign },
    { "dupe",     l_cmem_dupe },
    { "name",     l_cmem_name },
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
