#include "q_incs.h"
#include "init.h"
#include "setup.h"

int
setup(
    void
    )
{
  int status = 0;

  free_globals(); 
  zero_globals();
  status = init_lua(); cBYE(status);
BYE:
  return status;
}
