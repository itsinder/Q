#include <lua.h>
#include "q_incs.h"
#include "init.h"
#include "setup.h"
extern lua_State *g_L_DT; 

int
setup(
    void
    )
{
  int status = 0;

  free_globals(); 
  zero_globals();
BYE:
  return status;
}
