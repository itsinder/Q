#include "q_incs.h"
#include "dnn_types.h"
#include "core_dnn.h"
static void
free_z_a(
    int nl, 
    int *npl, 
    int bsz, 
    float ****ptr_z)
{
  float ***z = *ptr_z;

  *ptr_z = NULL;
}
//----------------------------------------------------

static int
malloc_z_a(
    int nl, 
    int *npl, 
    int bsz, 
    float ****ptr_z)
{
  int status = 0;
  float ***z = *ptr_z = NULL;

  *ptr_z = z;
BYE:
  return status;
}

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
  status = dnn_free(ptr_X); cBYE(status);
BYE:
  return status;
}
//----------------------------------------------------
int
dnn_bprop(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
BYE:
  return status;
}

//----------------------------------------------------
int
dnn_fstep(
    DNN_REC_TYPE *ptr_X,
    float **cptrs_in, /* [npl[0]][nI] */
    float **cptrs_out, /* [npl[nl-1]][nI] */
    uint64_t nI // number of instances
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
int dnn_set_io(
    DNN_REC_TYPE *ptr_dnn, 
    int nl, 
    int *npl, 
    int bsz
    )
{
  int status = 0;
  float ***z = NULL;
  float ***a = NULL;
  status = malloc_z_a(nl, npl, bsz, &z); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &a); cBYE(status);

BYE:
  if ( status < 0 ) { 
    free_z_a(nl, npl, bsz, &z); 
    free_z_a(nl, npl, bsz, &a); 
  }
  return status;
}
//----------------------------------------------------

int
dnn_new(
    DNN_REC_TYPE *ptr_X,
    int nl,
    int *npl
    )
{
  int status = 0;
  float ***W = NULL;
  float **b  = NULL;
  
  memset(ptr_X, '\0', sizeof(DNN_REC_TYPE));
  //--------------------------------------
  if ( nl < 3 ) { go_BYE(-1); }
  ptr_X->nl  = nl;
  //--------------------------------------
  for ( int i = 1; i < nl; i++ ) { 
    if ( npl[i] < 1 ) { go_BYE(-1); }
  }
  // TODO P1: Current implementation assumes last layer has 1 neuron
  if ( npl[nl-1] != 1 ) { go_BYE(-1); }
  //--------------------------------------
  int *tmp = malloc(nl * sizeof(int));
  return_if_malloc_failed(tmp);
  memcpy(tmp, npl, nl * sizeof(int));
  ptr_X->npl = tmp;
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
