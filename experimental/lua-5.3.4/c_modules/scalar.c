#define LUA_LIB

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "vec.h"
#include "_txt_to_I1.h"
#include "_txt_to_I2.h"
#include "_txt_to_I4.h"
#include "_txt_to_I8.h"
#include "_txt_to_F4.h"
#include "_txt_to_F8.h"

// TODO Move following decl

static int l_sclr_eq( lua_State *L);
typedef enum _qtype_type { undef, I1, I2, I4, I8, F4, F8} QTYPE;

typedef union _cdata_type {
  int8_t  valI1;
  int16_t valI2;
  int32_t valI4;
  int64_t valI8;
  float   valF4;
  double  valF8;
} CDATA_TYPE;

typedef struct _sclr_rec_type {
  char field_type[8];
  CDATA_TYPE cdata;
} SCLR_REC_TYPE;

LUAMOD_API int luaopen_libsclr (lua_State *L);

static int l_sclr_to_str( lua_State *L) {
int status = 0;
#define BUFLEN 31
  char buf[BUFLEN+1];

  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  // TODO Allow user to provide format
  memset(buf, '\0', BUFLEN+1);
  const char *field_type = ptr_sclr->field_type;
  if ( strcmp(field_type, "I1" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI1);
  }
  else if ( strcmp(field_type, "I2" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI2);
  }
  else if ( strcmp(field_type, "I4" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI4);
  }
  else if ( strcmp(field_type, "I8" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%lld", ptr_sclr->cdata.valI8);
  }
  else if ( strcmp(field_type, "F4" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%f", ptr_sclr->cdata.valF4);
  }
  else if ( strcmp(field_type, "F8" ) == 0 ) { 
    snprintf(buf, BUFLEN, "%lf", ptr_sclr->cdata.valF8);
  }
  else {
    go_BYE(-1);
  }
  lua_pushstring(L, buf);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_to_str. ");
  return 2;
}
//----------------------------------------
static int l_sclr_new( lua_State *L) {
  int status = 0;
  int8_t  tempI1;
  int16_t tempI2;
  int32_t tempI4;
  int64_t tempI8;
  float   tempF4;
  double  tempF8;

  const char *str_val = luaL_checkstring(L, 1);
  const char *qtype   = luaL_checkstring(L, 2);
  SCLR_REC_TYPE *ptr_sclr = NULL;
  ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  char *dst = (char *)&(ptr_sclr->cdata);
  if ( qtype == NULL ) {
    // TODO Infer qtype 
    go_BYE(-1);
  }
  if ( strcmp(qtype, "I1" ) == 0 ) { 
    status = txt_to_I1(str_val, &tempI1); cBYE(status);
    memcpy(dst, &tempI1, 1); strcpy(ptr_sclr->field_type, "I1"); 
  }
  else if ( strcmp(qtype, "I2" ) == 0 ) { 
    status = txt_to_I2(str_val, &tempI2); cBYE(status);
    memcpy(dst, &tempI2, 2); strcpy(ptr_sclr->field_type, "I2"); 
  }
  else if ( strcmp(qtype, "I4" ) == 0 ) { 
    status = txt_to_I4(str_val, &tempI4); cBYE(status);
    memcpy(dst, &tempI4, 4); strcpy(ptr_sclr->field_type, "I4"); 
  }
  else if ( strcmp(qtype, "I8" ) == 0 ) { 
    status = txt_to_I8(str_val, &tempI8); cBYE(status);
    memcpy(dst, &tempI8, 8); strcpy(ptr_sclr->field_type, "I8"); 
  }
  else if ( strcmp(qtype, "F4" ) == 0 ) { 
    status = txt_to_F4(str_val, &tempF4); cBYE(status);
    memcpy(dst, &tempF4, 4); strcpy(ptr_sclr->field_type, "F4"); 
  }
  else if ( strcmp(qtype, "F8" ) == 0 ) { 
    status = txt_to_F8(str_val, &tempF8); cBYE(status);
    memcpy(dst, &tempF8, 8); strcpy(ptr_sclr->field_type, "F8"); 
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
//-----------------------
static const struct luaL_Reg sclr_methods[] = {
    { NULL,          NULL               },
};
 
static const struct luaL_Reg sclr_functions[] = {
    { "new", l_sclr_new },
    { "to_str", l_sclr_to_str },
    { "eq", l_sclr_eq },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/
LUAMOD_API int luaopen_libsclr (lua_State *L) {
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

  /* Register the object.func functions into the table that is at the 
   * top of the stack. */

  /* Set the methods to the metatable that should be accessed via
   * object:func */
  luaL_setfuncs(L, sclr_methods, 0);

  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  luaL_newlib(L, sclr_functions);

  return 1;
}

static int l_sclr_eq( lua_State *L) {
  int status = 0;
  int ret_val = 0;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  if ( strcmp(ptr_sclr1->field_type, "I1") == 0 ) { 
    if ( strcmp(ptr_sclr2->field_type, "I1") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI1 == ptr_sclr2->cdata.valI1;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I2") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI1 == ptr_sclr2->cdata.valI2;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI1 == ptr_sclr2->cdata.valI4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI1 == ptr_sclr2->cdata.valI8;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI1 == ptr_sclr2->cdata.valF4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI1 == ptr_sclr2->cdata.valF8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr1->field_type, "I2") == 0 ) { 
    if ( strcmp(ptr_sclr2->field_type, "I1") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI2 == ptr_sclr2->cdata.valI1;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I2") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI2 == ptr_sclr2->cdata.valI2;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI2 == ptr_sclr2->cdata.valI4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI2 == ptr_sclr2->cdata.valI8;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI2 == ptr_sclr2->cdata.valF4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI2 == ptr_sclr2->cdata.valF8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr1->field_type, "I4") == 0 ) { 
    if ( strcmp(ptr_sclr2->field_type, "I1") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI4 == ptr_sclr2->cdata.valI1;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I2") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI4 == ptr_sclr2->cdata.valI2;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI4 == ptr_sclr2->cdata.valI4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI4 == ptr_sclr2->cdata.valI8;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI4 == ptr_sclr2->cdata.valF4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI4 == ptr_sclr2->cdata.valF8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr1->field_type, "I8") == 0 ) { 
    if ( strcmp(ptr_sclr2->field_type, "I1") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI8 == ptr_sclr2->cdata.valI1;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I2") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI8 == ptr_sclr2->cdata.valI2;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI8 == ptr_sclr2->cdata.valI4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI8 == ptr_sclr2->cdata.valI8;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI8 == ptr_sclr2->cdata.valF4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valI8 == ptr_sclr2->cdata.valF8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr1->field_type, "F4") == 0 ) { 
    if ( strcmp(ptr_sclr2->field_type, "I1") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF4 == ptr_sclr2->cdata.valI1;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I2") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF4 == ptr_sclr2->cdata.valI2;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF4 == ptr_sclr2->cdata.valI4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF4 == ptr_sclr2->cdata.valI8;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF4 == ptr_sclr2->cdata.valF4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF4 == ptr_sclr2->cdata.valF8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr1->field_type, "F8") == 0 ) { 
    if ( strcmp(ptr_sclr2->field_type, "I1") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF8 == ptr_sclr2->cdata.valI1;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I2") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF8 == ptr_sclr2->cdata.valI2;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF8 == ptr_sclr2->cdata.valI4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "I8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF8 == ptr_sclr2->cdata.valI8;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F4") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF8 == ptr_sclr2->cdata.valF4;
    }
    else if ( strcmp(ptr_sclr2->field_type, "F8") == 0 ) { 
      ret_val = ptr_sclr1->cdata.valF8 == ptr_sclr2->cdata.valF8;
    }
    else {
      go_BYE(-1);
    }
  }
  lua_pushinteger(L, ret_val);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_eq. ");
  return 2;
}
