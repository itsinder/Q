#ifndef __DNN_TYPES_H
#define __DNN_TYPES_H

typedef float(* __act_fn_t )(float *, int, float *);

typedef enum act_fn_type { 
  undef_act_fn, RELU, SIGMOID, SOFT_MAX, TANH, LEAKY_RELU
} ACT_FN_TYPE;

/* Items marked [1] are created by new */
/* Items marked [2] are created by set_io */
typedef struct _dnn_rec_type {
/*[1]*/  int nl; // num layers
/*[1]*/  int *npl;  // neurons per layer  [num_layers]
/*[1]*/  __act_fn_t  *A; // activation_function[num_layers] 
/*[1]*/  float ***W; // weights, 
/*[1]*/  float **b; // bias, 
/*[1]*/  uint8_t **d; // [num_layers][neurons_in_layer[i]]
/* Note that we need a bit for d (in or out) burt we use 8 bits */
/*[1]*/  float *dpl; // dropout per layer [num_layers]
  /* W[0] = NULL
   * W[i] = [num_layers][neurons_in_layer[i-1]][neurons_in_layer[i]]
   * b[0] = NULL
   * b[i] = [num_layers][neurons_in_layer[i]]
   * */
/*[2]*/  int bsz; // batch size
/* Do not allocate or de-allocate in/out. These are external */
/*[2]*/  float **in; // Input data, [neurons_in_layer[0]][num_instances]
/*[2]*/  int num_instances; // 
/*[2]*/  float **out; // Output data, [neurons_in_layer[nl-1]][num_instances]

/*[3]*/  float ***z; 
/* z[0] == NULL
   z[i] = [num_layers][neurons_per_layer[l]][bsz]
   */
/*[3]*/  float ***a; 
/*
   a[0] == NULL
   a[i] = [num_layers][neurons_per_layer[l]][bsz]
*/
float ***zprime;  /* for testing */
float ***aprime;  /* for testing */
//------------------------------------------------------------
} DNN_REC_TYPE;
#endif // _DNN_TYPES_H
