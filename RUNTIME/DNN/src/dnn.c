#include "q_incs.h"
#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "dnn_types.h"
#include "core_dnn.h"
#include "cmem.h"

int luaopen_libdnn (lua_State *L);
//----------------------------------------
static int l_dnn_epoch( lua_State *L) {
  DNN_REC_TYPE *ptr_dnn = (DNN_REC_TYPE *)luaL_checkudata(L, 1, "Dnn");
  int status = dnn_epoch(ptr_dnn); cBYE(status);
  lua_pushboolean(L, true); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_dnn_check( lua_State *L) {
  DNN_REC_TYPE *ptr_dnn = (DNN_REC_TYPE *)luaL_checkudata(L, 1, "Dnn");
  int status = dnn_check(ptr_dnn); cBYE(status);
  lua_pushboolean(L, true); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_dnn_delete( lua_State *L) {
  DNN_REC_TYPE *ptr_dnn = (DNN_REC_TYPE *)luaL_checkudata(L, 1, "Dnn");
  int status = dnn_delete(ptr_dnn);cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
// TODO: Do we need this or can we just use l_dnn_delete()?
static int l_dnn_free( lua_State *L) {
  DNN_REC_TYPE *ptr_dnn = (DNN_REC_TYPE *)luaL_checkudata(L, 1, "Dnn");
  int status = dnn_free(ptr_dnn);cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_dnn_new( lua_State *L) 
{
  int status = 0;
  DNN_REC_TYPE *ptr_dnn = NULL;

  int bsz = luaL_checknumber(L, 1); // batch size 
  int nl  = luaL_checknumber(L, 2); // num layers
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 3, "CMEM");
  if ( ptr_cmem == NULL ) { go_BYE(-1); }
  if ( nl < 3 ) { go_BYE(-1); }
  if ( bsz < 1 ) { go_BYE(-1); }
  float *npl = (float *)ptr_cmem->data;
  if ( strcmp(ptr_cmem->field_type, "F4") != 0 ) { go_BYE(-1); }

  ptr_dnn = (DNN_REC_TYPE *)lua_newuserdata(L, sizeof(DNN_REC_TYPE));
  return_if_malloc_failed(ptr_dnn);
  memset(ptr_dnn, '\0', sizeof(DNN_REC_TYPE));
  luaL_getmetatable(L, "Dnn"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = dnn_new(ptr_dnn, bsz, nl, npl);
  cBYE(status);

  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not create DNN\n");
  return 2;
}
//-----------------------
static const struct luaL_Reg dnn_methods[] = {
    { "__gc",    l_dnn_free   },
    { "check", l_dnn_check },
    { "delete", l_dnn_delete },
    { "epoch", l_dnn_epoch },
//    { "hydrate", l_dnn_hydrate },
//    { "meta", l_dnn_meta },
//    { "serialize", l_dnn_serialize },
//    { "test", l_dnn_test }, // TOOD SHould we have a test1 ?
    { NULL,          NULL               },
};
 
static const struct luaL_Reg dnn_functions[] = {
    { "check", l_dnn_check },
    { "delete", l_dnn_delete },
    { "epoch", l_dnn_epoch },
//    { "hydrate", l_dnn_hydrate },
//    { "meta", l_dnn_meta },
    { "new", l_dnn_new },
//    { "serialize", l_dnn_serialize },
//    { "test", l_dnn_test }, // TOOD SHould we have a test1 ?
    { NULL,  NULL         }
  };

  /*
  ** Open vector library
  */
  int luaopen_libdnn (lua_State *L) {
    /* Create the metatable and put it on the stack. */
    luaL_newmetatable(L, "Dnn");
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
    luaL_register(L, NULL, dnn_methods);

    int status = luaL_dostring(L, "return require 'Q/UTILS/lua/q_types'");
    if ( status != 0 ) {
      WHEREAMI;
      fprintf(stderr, "Running require failed:  %s\n", lua_tostring(L, -1));
      exit(1);
    } 
    luaL_getmetatable(L, "Dnn");
    lua_pushstring(L, "Dnn");
    status =  lua_pcall(L, 2, 0, 0);
    if (status != 0 ) {
       WHEREAMI; 
       fprintf(stderr, "Type Registering failed: %s\n", lua_tostring(L, -1));
       exit(1);
    }

    /* Register the object.func functions into the table that is at the
     * top of the stack. */
    lua_createtable(L, 0, 0);
    luaL_register(L, NULL, dnn_functions);
    // Why is return code not 0
    return 1;
}
