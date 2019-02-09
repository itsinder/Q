#include "q_incs.h"
#include "dnn_types.h"
#include "core_dnn.h"

int
dnn_check(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
BYE:
  return status;
}

int
dnn_delete(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
BYE:
  return status;
}

int
dnn_epoch(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
BYE:
  return status;
}

int
dnn_free(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
  if ( ptr_X == NULL ) { go_BYE(-1); }
  if ( ptr_X->nl < 3 ) { go_BYE(-1); }
  free_if_non_null(ptr_X->npl);
  // fprintf(stderr, "garbage collection done\n");

BYE:
  return status;
}

int
dnn_new(
    DNN_REC_TYPE *ptr_X,
    int bsz,
    int nl,
    float *npl
    )
{
  int status = 0;
  
  memset(ptr_X, '\0', sizeof(DNN_REC_TYPE));
  //--------------------------------------
  float *tmp = malloc(nl * sizeof(float));
  return_if_malloc_failed(tmp);
  memcpy(tmp, npl, nl * sizeof(float));
  ptr_X->npl = tmp;
  //--------------------------------------
  if ( bsz < 1 ) { go_BYE(-1); }
  ptr_X->bsz = bsz;
  //--------------------------------------
  if ( nl < 3 ) { go_BYE(-1); }
  ptr_X->nl  = nl;
  //--------------------------------------

BYE:
  if ( status < 0 ) { 
    free_if_non_null(ptr_X->npl);
  }
  return status;
}

