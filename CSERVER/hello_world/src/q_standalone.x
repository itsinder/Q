#include "q_incs.h"
#include "q_globals.h"
#include "init.h"
#include "auxil.h"
#include "setup.h"

int 
main(
    int argc, 
    char **argv
    )
{
  // signal(SIGINT, halt_server); TODO 
  int status = 0;

  zero_globals();
  //----------------------------------
  if ( argc != 2 ) { go_BYE(-1); }
  status = setup(); cBYE(status);
  pthread_mutex_init(&g_mutex, NULL);	
  pthread_cond_init(&g_condc, NULL);
  pthread_cond_init(&g_condp, NULL);
  status = pthread_create(&g_con, NULL, &post_from_log_q, NULL);
  if ( status != 0 ) { go_BYE(-1); }
  status = execute(argv[1]); 
  // status = halt(os.getenv("Q_METAFILE"));
BYE:
  free_globals();
  return status;
}
