#include <sys/time.h>
#include "q_incs.h"
#include "dnn_types.h"
#include "core_dnn.h"
#include "fstep_a.h"
#include "bstep.h"

#ifdef RASPBERRY_PI
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
#endif
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
free_da(
    int nl,
    int *npl,
    float ****ptr_z
    )
{
  /*
  float ***z = *ptr_z;
  TODO

  *ptr_z = NULL;
*/
}

//----------------------------------------------------
static void
free_z_a(
    int nl, 
    int *npl,
    float ****ptr_z
    )
{
  /*
  float ***z = *ptr_z;
  TODO

  *ptr_z = NULL;
*/
}
//----------------------------------------------------
static int
check_z_a(
    int nl, 
    int *npl, 
    int bsz, 
    float ***z,
    float ***zprime
    )
{
  int status = 0;
  if ( z == zprime ) { go_BYE(-1); }
  for ( int i = 1; i < nl; i++ ) { 
    for ( int j = 0; j < npl[i]; j++ ) { 
      for ( int k = 0; k < bsz; k++ )  {
        // printf("%f:%f \n", z[i][j][k], zprime[i][j][k]);
        if ( ( fabs(z[i][j][k] - zprime[i][j][k]) /  
               fabs(z[i][j][k] + zprime[i][j][k]) ) > 0.0001 ) { 
          printf("difference [%d][%d][%d]\n", i, j, k); 
          go_BYE(-1); 
        }
      }
    }
  }
BYE:
  return status;
}


static int
malloc_b(
    int nl,
    int *npl,
    float ***ptr_b
    )
{
  int status = 0;
  float **b = NULL;
  b = malloc(nl * sizeof(float *));
  return_if_malloc_failed(b);
  b[0] = NULL;
  for ( int l = 1; l < nl; l++ ) { 
    int L_next = npl[l];
    b[l] = malloc(L_next * sizeof(float));
    return_if_malloc_failed(b[l]);
  }
  *ptr_b = b;
BYE:
  return status;
}
static int
malloc_W(
    int nl,
    int *npl,
    float ****ptr_W
    )
{
  int status = 0;
  float *** W = NULL;
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
  *ptr_W = W;
BYE:
  return status;
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
  float  ***dW  = ptr_dnn->dW;
  float   **db  = ptr_dnn->db;
  uint8_t  **d = ptr_dnn->d;
  float   *dpl = ptr_dnn->dpl;
  float   ***z = ptr_dnn->z;
  float   ***a = ptr_dnn->a;
  float   ***dz = ptr_dnn->dz;
  float   ***da = ptr_dnn->da;
  float   ***zprime = ptr_dnn->zprime;
  float   ***aprime = ptr_dnn->aprime;
  __act_fn_t  *A = ptr_dnn->A;
  __bak_act_fn_t  *bak_A = ptr_dnn->bak_A;

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
  for ( int bidx = 0; bidx < num_batches; bidx++ ) {
    int lb = bidx  * batch_size;
    int ub = lb + batch_size;
    if ( bidx == (num_batches-1) ) { ub = nI; }
    if ( ( ub - lb ) > batch_size ) { go_BYE(-1); }

    float **in;
    float **out_z;
    float **out_a;
    for ( int l = 1; l < nl; l++ ) { // For each layer
      // Note that loop starts from 1, not 0
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
    }
#ifdef TEST_VS_PYTHON
    status = check_z_a(nl, npl, batch_size, z, zprime); cBYE(status);
    status = check_z_a(nl, npl, batch_size, a, aprime); cBYE(status);
    printf("SUCCESS\n"); 
    //exit(0);
#endif


    // da = - (np.divide(y, y_hat) - np.divide(1 - y, 1 - y_hat))
    // da = Q.sub(Q.div(Q.sub(1, y), Q.sub(1, yhat)), Q.div(y/ yhat))
    //
    // s = 1 / (1 + np.exp(-z))
    // dz = da * s * (1 - s)

    // s = Q.reciprocal(Q.vsadd(Q.exp(Q.vsmul(z, -1)), 1))
    // dz = Q.vvmul(da, Q.vvmul(s, Q.vssub(1, s)))
#define ALPHA 0.0075 // TODO This is a user supplied parameter

    float **da_last = da[nl-1];
    float **a_last  =  a[nl-1];
    float **z_last  =  z[nl-1];
    float **out = cptrs_out;
    int num_in_last = npl[nl-1];
    for ( int j = 0; j < num_in_last; j++ ) { // for neurons in last layer
      float *out_j     = out[j];
      float *a_j       = a_last[j];
      float *da_last_j = da_last[j];
      for ( int i = 0; i < batch_size; i++ ) { // for each instance
        da_last_j[i] = - ( ( out_j[i] / a_j[i] ) 
            - ( ( 1 - out_j[i] ) / ( 1 - a_j[i] ) ) );
      }
    } // da[3] has been computed
    printf("Generated da for last layer\n");

    for ( int l = nl-1; l > 0; l-- ) { // for layer, starting from last
      float **z_l  = z[l];
      float **da_l = da[l];
      float **dz_l = dz[l];
      for ( int j = 0; j < npl[l]; j++ ) { // for neurons in layer l
        float *z_l_j = z_l[j];
        float *da_l_j = da_l[j];
        float *dz_l_j = dz_l[j];
        status = bak_A[l](z_l_j, da_l_j, batch_size, dz_l_j);
        cBYE(status);
      } // dz[l] has been computed

      if ( l >= 2 ) { // to avoid computing da[0], which is NULL
        float **W_l = W[l];
        float **da_l_minus_one = da[l-1];
        for ( int j = 0; j < npl[l]; j++ ) { // for neurons in layer l
          float *dz_l_j = dz_l[j];
          for ( int jprime = 0; jprime < npl[l-1]; jprime++ ) { // for neurons in layer (l-1)
            float *W_l_jprime = W_l[jprime];
            float *da_l_minus_one_jprime = da_l_minus_one[jprime];
            for ( int i = 0; i < batch_size; i++ ) {
              da_l_minus_one_jprime[i] += dz_l_j[i] * W_l_jprime[j];
            }
          }
        }
      }
    }
    printf("Generated dz and da_prev\n");

    for ( int l = nl-1; l > 0; l-- ) { // back prop through other layers
      float **dW_l = dW[l];
      float  *db_l = db[l];
      float **dz_l = dz[l];
      float **a_l  = a[l];
      float **a_l_minus_one = a[l-1];
      if ( l == 1 ) { // a[0] is NULL
        a_l_minus_one = cptrs_in;
      }
      for ( int j = 0; j < npl[l]; j++ ) { // for neurons in last layer
        float *dz_l_j = dz_l[j];
        float *a_l_j  =  a_l[j];
        float sum = 0;
        //     dw = (1. / m) * np.dot(dz, a_prev.T)
        for ( int jprime = 0; jprime < npl[l-1]; jprime++ ) { 
          sum = 0;
          float *a_l_minus_one_jprime = a_l_minus_one[jprime];
          for ( int i = 0; i < batch_size; i++ ) {
            sum += dz_l_j[i] * a_l_minus_one_jprime[i];
          }
          sum /= batch_size;
          dW_l[jprime][j] = sum;
        }
        sum = 0;
        for ( int i = 0; i < batch_size; i++ ) { 
          sum += dz_l_j[i];
        }
        sum /= batch_size;
        db_l[j] = sum;
      }
      printf("HERE AI AM %d \n", l);
    }
    exit(0);
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
  float ***dz = ptr_dnn->dz;
  float ***da = ptr_dnn->da;
  int nl = ptr_dnn->nl;
  int *npl = ptr_dnn->npl;
  free_z_a(nl, npl, &z); 
  free_z_a(nl, npl, &a);
  free_z_a(nl, npl, &dz);
  free_da(nl, npl, &da); 
#ifdef TEST_VS_PYTHON
  z = ptr_dnn->zprime;
  a = ptr_dnn->aprime;
  free_z_a(nl, npl, &z); 
  free_z_a(nl, npl, &a); 
#endif
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

  float ***dz = NULL;
  float ***da = NULL;

  int nl = ptr_dnn->nl;
  int *npl = ptr_dnn->npl;
  ptr_dnn->bsz = bsz;
  status = malloc_z_a(nl, npl, bsz, &z); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &a); cBYE(status);
  ptr_dnn->z = z;
  ptr_dnn->a = a;

  status = malloc_z_a(nl, npl, bsz, &dz); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &da); cBYE(status);
  ptr_dnn->dz = dz;
  ptr_dnn->da = da;
#ifdef TEST_VS_PYTHON
  z = a = NULL; // not necessary but to show we are re-initializing
  status = malloc_z_a(nl, npl, bsz, &z); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &a); cBYE(status);
#include "../test/_set_Z.c" // FOR TESTING 
#include "../test/_set_A.c" // FOR TESTING 
  ptr_dnn->zprime = z;
  ptr_dnn->aprime = a;
#endif
BYE:
  if ( status < 0 ) { 
    free_z_a(nl, npl, &z); 
    free_z_a(nl, npl, &a);
    free_z_a(nl, npl, &dz);
    free_da(nl, npl, &da);
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
  __bak_act_fn_t  *bak_A = NULL;

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

  bak_A = malloc(nl * sizeof(__bak_act_fn_t));
  memset(bak_A, '\0',  (nl * sizeof(__bak_act_fn_t)));

  for ( int i = 0; i < nl; i++ ) { 
    char *cptr;
    if ( i == 0 ) {
      cptr = strtok((char *)afns, ":");
    }
    else {
      cptr = strtok(NULL, ":");
    }
    if ( i == 0 ) { /* input layer has no activation function */
      if ( strcmp(cptr, "NONE") != 0 ) { go_BYE(-1); }
      A[0] = identity;
      continue; 
    }
    if ( strcmp(cptr, "sigmoid") == 0 ) {
      A[i]     = sigmoid;
      bak_A[i] = sigmoid_bak;
    }
    else if ( strcmp(cptr, "relu") == 0 ) {
      A[i]     = relu;
      bak_A[i] = relu_bak;
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
  ptr_X->A  = A;
  ptr_X->bak_A  = bak_A;
  //--------------------------------------
  status = malloc_W(nl, npl, &W); cBYE(status);
  ptr_X->W  = W;
#ifdef TEST_VS_PYTHON
#include "../test/_set_W.c" // FOR TESTING 
#endif
  W = NULL;
  status = malloc_W(nl, npl, &W); cBYE(status);
  ptr_X->dW  = W;
  //--------------------------------------
  status = malloc_b(nl, npl, &b); cBYE(status);
  ptr_X->b  = b;
#ifdef TEST_VS_PYTHON
#include "../test/_set_B.c" // FOR TESTING 
#endif
  b = NULL;
  status = malloc_b(nl, npl, &b); cBYE(status);
  ptr_X->db  = b;
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
