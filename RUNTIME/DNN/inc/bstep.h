#include "act_fns.h"
extern int
bstep(
    float **in,  /* da as input */
    float **f_a,   /* value of 'a' in forward propagation */
    float **f_z,    /* value of 'z' in forward propagation */
    uint8_t *d_in,   /* [n_in]  dropout for input layer */
    uint8_t *d_out,  /* [n_out] dropout for output layer */
    float **out_dz, /* [n_out][nI] */
    float **out_da, /* [n_out][nI] */
//    float **out_dw,
//    float **out_db,
    int32_t nI, /* number of instances */
    int32_t n_in,  /* neurons in input layer */
    int32_t n_out,  /* neurons in output layer */
    __bak_act_fn_t afn
   );
