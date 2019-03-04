#include <sys/time.h>
#include "q_incs.h"
#include "dnn_types.h"
#include "core_dnn.h"
#include "fstep_a.h"

static void
set_W(
    float ***W
    )
{
  /*
     W[1][0] = = 0.17511345;
     W[1][1] = -0.4797196;
     W[2][1] = -0.30251271;
     , -0.32758364, -0.15845926,
   = 0.17511345, -0.47971962, -0.30251271, -0.32758364, -0.15845926,
         0.13971159, -0.25937964,  0.21091907,  0.04563044,  0.23632542],
       [-0.10095298, -0.19570727,  0.34871516, -0.58248266,  0.12900959,
         0.29941416,  0.1690164 , -0.06477899, -0.08915248,  0.00968901],
       [-0.22156274,  0.21357835,  0.02842162, -0.19919548,  0.33684907,
        -0.21418677,  0.44400973, -0.39859007, -0.13523984, -0.05911348],
       [-0.72570658,  0.19094223, -0.05694645,  0.05892507,  0.04916247,
        -0.04978276, -0.14645337,  0.20778173, -0.4079519 , -0.04742307]]), 
        */
}

static uint64_t 
get_time_usec(
    void
    )
{
  struct timeval Tps; 
  struct timezone Tpf;
  gettimeofday (&Tps, &Tpf);
  return ((uint64_t )Tps.tv_usec + 1000000* (uint64_t )Tps.tv_sec);
}
static uint64_t
RDTSC(
    void
    )
//STOP_FUNC_DECL  
{
#ifdef RASPBERRY_PI
  return get_time_usec();
#else
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
#endif
}
static int 
set_dropout(
    uint8_t *d, /* [num neurons ] */
    float dpl,  /* probability of dropout */
    int n       /* num neurons */
    )
{
  int status = 0;
  if ( d == NULL ) { go_BYE(-1); }
  if ( n <= 0    ) { go_BYE(-1); }
  if ( dpl < 0 ) { go_BYE(-1); }
  if ( dpl >= 1 ) { go_BYE(-1); }
  memset(d, '\0', (sizeof(uint8_t) * n)); // nobody dropped out
  if ( dpl > 0 ) { 
    for ( int i = 0; i < n; i++ ) { 
      double dtemp = drand48();
      if ( dtemp > dpl ) { 
        d[i] = 1; // ith neuron will be dropped
      }
    }
  }
  // TODO: Make sure at least one node is alive after dropout
BYE:
  return status;
}

static void
free_z_a(
    int nl, 
    int *npl,
    float ****ptr_z
    )
{
  /*
  float ***z = *ptr_z;

  *ptr_z = NULL;
*/
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
  z = malloc(nl * sizeof(float **));
  return_if_malloc_failed(z);
  memset(z, '\0', nl * sizeof(float **));

  z[0] = NULL;
  for ( int i = 1; i < nl; i++ ) { 
    z[i] = malloc(npl[i] * sizeof(float *));
    return_if_malloc_failed(z[i]);
    memset(z[i], '\0', npl[i] * sizeof(float *));
  }
  for ( int i = 1; i < nl; i++ ) { 
    for ( int j = 0; j < npl[i]; j++ ) { 
      z[i][j] = malloc(bsz * sizeof(float));
      return_if_malloc_failed(z[i][j]);
    }
  }
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
  int nl = ptr_X->nl;
  int    *npl = ptr_X->npl;
  float  *dpl = ptr_X->dpl;
  float  ***W = ptr_X->W;
  float  **b = ptr_X->b;
  float ***a = ptr_X->z;
  float ***z = ptr_X->z;
  __act_fn_t *A = ptr_X->A;
  //-------------------------
  if ( ( a == NULL ) && ( z != NULL ) ) { go_BYE(-1); }
  if ( ( a != NULL ) && ( z == NULL ) ) { go_BYE(-1); }
  if ( a != NULL ) { 
    if ( a[0] != NULL ) { go_BYE(-1); }
    if ( z[0] != NULL ) { go_BYE(-1); }
    for ( int l = 1; l < nl; l++ ) { 
      if ( a[l] == NULL ) { go_BYE(-1); }
      if ( z[l] == NULL ) { go_BYE(-1); }
      for ( int j = 0; j < npl[l]; j++ ) { 
        if ( a[l][j] == NULL ) { go_BYE(-1); }
        if ( z[l][j] == NULL ) { go_BYE(-1); }
      }
    }
  }

  if ( nl < 3 ) { go_BYE(-1); }
  //-----------------------------------
  if ( npl == NULL ) { go_BYE(-1); }
  for ( int i = 0; i < ptr_X->nl; i++ ) { 
    if ( npl[i] < 1 ) { go_BYE(-1); 
    }
  }
  //-----------------------------------
  if ( dpl == NULL ) { go_BYE(-1); }
  for ( int i = 0; i < ptr_X->nl; i++ ) { 
    if ( dpl[i] > 1 ) { go_BYE(-1); 
    }
  }
  //-----------------------------------
  if ( A == NULL ) { go_BYE(-1); }
  //-----------------------------------
  if ( W == NULL ) { go_BYE(-1); }
  if ( W[0] != NULL ) { go_BYE(-1); }
  for ( int lidx = 1; lidx < nl; lidx++ ) { 
    if ( W[lidx] == NULL ) { go_BYE(-1); }
    int L_prev = npl[lidx-1];
    for ( int j = 0; j < L_prev; j++ ) { 
      if ( W[lidx][j] == NULL ) { go_BYE(-1); }
    }
  }
  //-----------------------------------
  if ( b == NULL ) { go_BYE(-1); }
  if ( b[0] != NULL ) { go_BYE(-1); }
  for ( int lidx = 1; lidx < nl; lidx++ ) { 
    if ( b[lidx] == NULL ) { go_BYE(-1); }
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
dnn_train(
    DNN_REC_TYPE *ptr_dnn,
    float **cptrs_in, /* [npl[0]][nI] */
    float **cptrs_out, /* [npl[nl-1]][nI] */
    uint64_t nI // number of instances
    )
{
  int status = 0;
  int batch_size = ptr_dnn->bsz;
  int nl = ptr_dnn->nl;
  int    *npl  = ptr_dnn->npl;
  float  ***W  = ptr_dnn->W;
  float   **b  = ptr_dnn->b;
  uint8_t  **d = ptr_dnn->d;
  float   *dpl = ptr_dnn->dpl;
  float   ***z = ptr_dnn->z;
  float   ***a = ptr_dnn->a;
  __act_fn_t  *A = ptr_dnn->A;

  if ( W   == NULL ) { go_BYE(-1); }
  if ( b   == NULL ) { go_BYE(-1); }
  if ( a   == NULL ) { go_BYE(-1); }
  if ( d   == NULL ) { go_BYE(-1); }
  if ( dpl == NULL ) { go_BYE(-1); }
  if ( z   == NULL ) { go_BYE(-1); }
  if ( npl == NULL ) { go_BYE(-1); }
  if ( nl  <  3    ) { go_BYE(-1); }
  if ( batch_size <= 0 ) { go_BYE(-1); }

  int num_batches = nI / batch_size;
  if ( ( num_batches * batch_size ) != (int)nI ) {
    num_batches++;
  }
  srand48(RDTSC());
  for ( int i = 0; i < num_batches; i++ ) {
    int lb = i  * batch_size;
    int ub = lb + batch_size;
    if ( i == (num_batches-1) ) { ub = nI; }
    if ( ( ub - lb ) > batch_size ) { go_BYE(-1); }

    float **in;
    float **out_z;
    float **out_a;
    for ( int l = 1; l < nl; l++ ) { // Note that loop starts from 1, not 0
      in  = a[l-1];
      out_z = z[l];
      out_a = a[l];
      if ( l == 1 ) { 
        in = cptrs_in; 
        /* Advance the pointers to get to the appropriate batch */
        for ( int j = 0; j < npl[0]; j++ ) { 
          in[j] += lb;
        }
        if ( a[l-1] != NULL ) { go_BYE(-1); }
        if ( z[l-1] != NULL ) { go_BYE(-1); }
      }
// WRONG      if ( l == nl-1 ) { out = cptrs_out; }
      /* the following if condition is important. To see why,
       * A: when l=1, we set dropouts for layer 0, 1 
       * B: when l=2, we set dropouts for layer 1, 2
       * but B would over-write the dropouts we set in A
       * this will cause errors */
      if ( l == 1 ) { 
        status = set_dropout(d[l-1], dpl[l-1], npl[l-1]); cBYE(status);
      }
      status = set_dropout(d[l],   dpl[l],   npl[l]); cBYE(status);
      status = fstep_a(in, W[l], b[l], 
          d[l-1], d[l], out_z, out_a, (ub-lb), npl[l-1], npl[l], A[l]);
      cBYE(status);
      /* Test z versus zprime */
      /* Test a versus zprime */
      /* TODO: do brop here */
    }
  }
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
  int *npl    = ptr_X->npl;
  float  ***W = ptr_X->W;
  float   **b = ptr_X->b;
  uint8_t **d = ptr_X->d;

  //---------------------------------------
  if ( W != NULL ) { 
    for ( int lidx = 1; lidx < nl; lidx++ ) { 
      int L_prev = npl[lidx-1];
      for ( int j = 0; j < L_prev; j++ ) { 
        free_if_non_null(W[lidx][j]);
      }
      free_if_non_null(W[lidx]);
    }
    free_if_non_null(W);
  }
  //---------------------------------------
  if ( b != NULL ) { 
    for ( int lidx = 1; lidx < nl; lidx++ ) { 
      free_if_non_null(b[lidx]);
    }
    free_if_non_null(b);
  }
  //---------------------------------------
  if ( d != NULL ) { 
    for ( int lidx = 0; lidx < nl; lidx++ ) { 
      free_if_non_null(d[lidx]);
    }
    free_if_non_null(d);
  }
  //---------------------------------------
  free_if_non_null(ptr_X->npl);
  free_if_non_null(ptr_X->dpl);
  // fprintf(stderr, "garbage collection done\n");

BYE:
  return status;
}
//----------------------------------------------------
int dnn_unset_bsz(
    DNN_REC_TYPE *ptr_dnn
    )
{
  int status = 0;
  float ***z = ptr_dnn->z;
  float ***a = ptr_dnn->a;
  int nl = ptr_dnn->nl;
  int *npl = ptr_dnn->npl;
  free_z_a(nl, npl, &z); 
  free_z_a(nl, npl, &a); 
  return status;
}
//----------------------------------------------------
int dnn_set_bsz(
    DNN_REC_TYPE *ptr_dnn, 
    int bsz
    )
{
  int status = 0;
  float ***z = NULL;
  float ***a = NULL;
  int nl = ptr_dnn->nl;
  int *npl = ptr_dnn->npl;
  ptr_dnn->bsz = bsz;
  status = malloc_z_a(nl, npl, bsz, &z); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &a); cBYE(status);
  ptr_dnn->z = z;
  ptr_dnn->a = a;
  /* START: For testing */
  status = malloc_z_a(nl, npl, bsz, &z); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &a); cBYE(status);
  ptr_dnn->zprime = z;
  ptr_dnn->aprime = a;
// #include "_test_z_a.c"
  /* STOP: For testing */
BYE:
  if ( status < 0 ) { 
    free_z_a(nl, npl, &z); 
    free_z_a(nl, npl, &a); 
  }
  return status;
}
//----------------------------------------------------

int
dnn_new(
    DNN_REC_TYPE *ptr_X,
    int nl,
    int *npl,
    float *dpl,
    const char * const afns
    )
{
  int status = 0;
  float   ***W = NULL;
  float   **b  = NULL;
  uint8_t **d  = NULL;
  __act_fn_t  *A = NULL;
  
  memset(ptr_X, '\0', sizeof(DNN_REC_TYPE));
  //--------------------------------------
  if ( nl < 3 ) { go_BYE(-1); }
  ptr_X->nl  = nl;
  //--------------------------------------
  for ( int i = 0; i < nl; i++ ) { 
    if ( npl[i] < 1 ) { go_BYE(-1); }
  }
  // TODO P1: Current implementation assumes last layer has 1 neuron
  if ( npl[nl-1] != 1 ) { go_BYE(-1); }
  int *itmp = malloc(nl * sizeof(int));
  return_if_malloc_failed(itmp);
  memcpy(itmp, npl, nl * sizeof(int));
  ptr_X->npl = itmp;
  //--------------------------------------
  // CAN HAVE DROPOUT IN INPUT LAYER  if ( dpl[0]    != 0 ) { go_BYE(-1); }
  if ( dpl[nl-1] != 0 ) { go_BYE(-1); }
  for ( int i = 1; i < nl-1; i++ ) { 
    if ( ( dpl[i] < 0 ) || ( dpl[i] >= 1 ) ) { go_BYE(-1); }
  }
  float *ftmp = malloc(nl * sizeof(float));
  return_if_malloc_failed(ftmp);
  memcpy(ftmp, dpl, nl * sizeof(float));
  ptr_X->dpl = ftmp;
  //--------------------------------------
  A = malloc(nl * sizeof(__act_fn_t));
  memset(A, '\0',  (nl * sizeof(__act_fn_t)));
  for ( int i = 0; i < nl; i++ ) { 
    char *cptr;
    if ( i == 0 ) {
      cptr = strtok((char *)afns, ":");
      if ( strcmp(cptr, "NONE") != 0 ) { go_BYE(-1); }
      A[i] = identity;
    }
    else {
      cptr = strtok(NULL, ":");
      if ( strcmp(cptr, "sigmoid") == 0 ) {
        A[i] = sigmoid;
      }
      else if ( strcmp(cptr, "relu") == 0 ) {
        A[i] = relu;
      }
      else if ( strcmp(cptr, "leaky_relu") == 0 ) {
        go_BYE(-1);
      }
      else if ( strcmp(cptr, "tanh") == 0 ) {
        go_BYE(-1);
      }
      else {
        go_BYE(-1);
      }
    }
  }
  ptr_X->A  = A;
  //--------------------------------------
  //--------------------------------------
  W = malloc(nl * sizeof(float **));
  return_if_malloc_failed(W);
  W[0] = NULL;
  for ( int l = 1; l < nl; l++ ) { 
    int L_prev = npl[l-1];
    int L_curr = npl[l];
    W[l] = malloc(L_prev * sizeof(float *));
    return_if_malloc_failed(W[l]);
    for ( int j = 0; j < L_prev; j++ ) { 
      W[l][j] = malloc(L_curr * sizeof(float));
      return_if_malloc_failed(W[l][j]);
    }
  }
  /* START: FOR BORIS TEST */
  // set_W(W);
#ifdef BORIS_TEST
#include "_set_w.c"
#endif
  /* STOP: FOR BORIS TEST */
  ptr_X->W  = W;
  //--------------------------------------
  b = malloc(nl * sizeof(float *));
  return_if_malloc_failed(b);
  b[0] = NULL;
  for ( int l = 1; l < nl; l++ ) { 
    int L_next = npl[l];
    b[l] = malloc(L_next * sizeof(float));
    return_if_malloc_failed(b[l]);
  }
  /* START: BORIS TEST */
  for ( int l = 1; l < nl; l++ ) { 
    for ( int j = 0; j < npl[l]; j++ ) { 
      b[l][j] = 0; 
    }
  }
  /* STOP : BORIS TEST */
  ptr_X->b  = b;
  //--------------------------------------
  d = malloc(nl * sizeof(uint8_t *));
  return_if_malloc_failed(d);
  for ( int l = 0; l < nl; l++ ) { 
    d[l] = malloc(npl[l] * sizeof(uint8_t));
    return_if_malloc_failed(d[l]);
  }
  ptr_X->d  = d;
  //--------------------------------------

BYE:
  if ( status < 0 ) { WHEREAMI; /* need to handle this better */ }
  return status;
}
