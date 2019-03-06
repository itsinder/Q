#include "q_incs.h"
#include "dnn_types.h"
#include "act_fns.h"

#include "bstep.h"

int bstep(
    float **in,  /* da as input */
    float **f_a,   /* value of 'a' in forward propagation */
    float **f_z,    /* value of 'z' in forward propagation */
    uint8_t *d_in,   /* [n_in]  dropout for input layer */
    uint8_t *d_out,  /* [n_out] dropout for output layer */
    float **out_dz, /* [n_in][nI] */
    float **out_da, /* [n_out][nI] */
//    float **out_dw,  // TODO: do the memory allocation for dw and db
//    float **out_db,
    int32_t nI, /* number of instances */
    int32_t n_in,  /* neurons in input layer */
    int32_t n_out,  /* neurons in output layer */
    __bak_act_fn_t afn
   )
{
  int status = 0;

  // This loop will produce the out_dz
  for ( int l = 0; l < n_in; l++ ) {
    if ( d_out[l] == true ) { continue; }
    float *in_l = in[l];
    float *f_z_l = f_z[l];
    float *out_dz_l = out_dz[l];
    status = afn(f_z_l, in_l, nI, out_dz_l);
    cBYE(status);
  }
  printf("Generated dz\n");

  /*
  // TODO: Produce dw, db, da
  for ( int k = (n_in-1); k > 0; k++ ) {
    if ( d_out[k] == true ) { continue; }
    float *dz_k = dz[k];
    float *f_a_k = f_a[k];
    float *out_dw_k = out_dw[k];
    for ( int l = 0; l < n_out; k++ ) {
      out_dw_l[k] = ( 1 / nI ) * ( )
    }
  }
  */
BYE:
  return status;
}
