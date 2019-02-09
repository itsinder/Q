#include "q_incs.h"
#include "dnn_types.h"
#include "core_dnn.h"

//----------------------------------------------------
int
dnn_check(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
  if ( ptr_X == NULL ) { go_BYE(-1); }
  if ( ptr_X->nl < 3 ) { go_BYE(-1); }
  if ( ptr_X->npl == NULL ) { go_BYE(-1); }
  if ( ptr_X->bsz < 1 ) { go_BYE(-1); }
  for ( int i = 0; i < ptr_X->nl; i++ ) { 
    if ( ptr_X->npl[i] < 1 ) { go_BYE(-1); 
    }
  }
  int nl = ptr_X->nl;
  int *npl = ptr_X->npl;
  float ***W = ptr_X->W;
  float **b = ptr_X->b;

  if ( W == NULL ) { go_BYE(-1); }
  if ( b == NULL ) { go_BYE(-1); }

  if ( W[0] != NULL ) { go_BYE(-1); }
  if ( b[0] != NULL ) { go_BYE(-1); }

  for ( int lidx = 1; lidx < nl; lidx++ ) { 
    if ( W[lidx] == NULL ) { go_BYE(-1); }
    if ( b[lidx] == NULL ) { go_BYE(-1); }
    int L_prev = npl[lidx-1];
    for ( int j = 0; j < L_prev; j++ ) { 
      if ( W[lidx][j] == NULL ) { go_BYE(-1); }
    }
  }
BYE:
  return status;
}
//----------------------------------------------------
int
dnn_delete(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
BYE:
  return status;
}
//----------------------------------------------------

int
dnn_epoch(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
BYE:
  return status;
}

//----------------------------------------------------
int
dnn_free(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
  if ( ptr_X == NULL ) { go_BYE(-1); }
  if ( ptr_X->nl < 3 ) { go_BYE(-1); }
  int nl = ptr_X->nl;
  int *npl = ptr_X->npl;
  float ***W = ptr_X->W;
  float **b = ptr_X->b;

  if ( W == NULL ) { go_BYE(-1); }
  for ( int lidx = 1; lidx < nl; lidx++ ) { 
    if ( W[lidx] == NULL ) { go_BYE(-1); }
    int L_prev = npl[lidx-1];
    for ( int j = 0; j < L_prev; j++ ) { 
      free_if_non_null(W[lidx][j]);
    }
    free_if_non_null(W[lidx]);
    free_if_non_null(b[lidx]);
  }
  free_if_non_null(W);
  free_if_non_null(b);
  free_if_non_null(ptr_X->npl);
  // fprintf(stderr, "garbage collection done\n");

BYE:
  return status;
}
//----------------------------------------------------

int
dnn_new(
    DNN_REC_TYPE *ptr_X,
    int bsz,
    int nl,
    int *npl
    )
{
  int status = 0;
  float ***W = NULL;
  float **b  = NULL;
  
  memset(ptr_X, '\0', sizeof(DNN_REC_TYPE));
  //--------------------------------------
  int *tmp = malloc(nl * sizeof(int));
  return_if_malloc_failed(tmp);
  memcpy(tmp, npl, nl * sizeof(int));
  ptr_X->npl = tmp;
  //--------------------------------------
  if ( bsz < 1 ) { go_BYE(-1); }
  ptr_X->bsz = bsz;
  //--------------------------------------
  if ( nl < 3 ) { go_BYE(-1); }
  ptr_X->nl  = nl;
  //--------------------------------------
  W = malloc(nl * sizeof(float **));
  return_if_malloc_failed(W);
  W[0] = NULL;
  for ( int lidx = 1; lidx < nl; lidx++ ) { 
    int L_prev = npl[lidx-1];
    int L_next = npl[lidx];
    W[lidx] = malloc(L_prev * sizeof(float *));
    return_if_malloc_failed(W[lidx]);
    for ( int j = 0; j < L_prev; j++ ) { 
      W[lidx][j] = malloc(L_next * sizeof(float *));
      return_if_malloc_failed(W[lidx][j]);
    }
  }
  ptr_X->W  = W;
  //--------------------------------------
  b = malloc(nl * sizeof(float *));
  return_if_malloc_failed(b);
  b[0] = NULL;
  for ( int lidx = 1; lidx < nl; lidx++ ) { 
    int L_next = npl[lidx];
    b[lidx] = malloc(L_next * sizeof(float *));
    return_if_malloc_failed(b[lidx]);
  }
  ptr_X->b  = b;

BYE:
  if ( status < 0 ) { WHEREAMI; /* need to handle this better */ }
  return status;
}
