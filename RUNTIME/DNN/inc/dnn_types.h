#ifndef __DNN_TYPES_H
#define __DNN_TYPES_H

typedef enum act_fn_type { 
  undef_act_fn, RELU, SIGMOID, SOFT_MAX, TANH, LEAKY_RELU
} ACT_FN_TYPE;

/* Items marked [1] are created by new */
/* Items marked [2] are created by set_io */
typedef struct _dnn_rec_type {
/*[1]*/  int nl; // num layers
/*[1]*/  int *npl;  // neurons per layer  [num_layers]
/*[1]*/  ACT_FN_TYPE  *A; // activation_function[num_layers] 
/*[1]*/  float ***W; // weights, [num_layers][][] 
/*[1]*/  float **b; // bias, [num_layers] [neurons_per_layer[l]]
  /* W[0] = NULL
   * W[i] = [neurons_in_layer[i-1]][neurons_in_layer[i]]
   * b[0] = NULL
   * b[i] = [neurons_in_layer[i]]
   * */
/*[2]*/  int bsz; // batch size
/*[2]*/  float **in; // Input data, [neurons_in_layer[0]][num_instances]
/*[2]*/  int num_instances; // 
/*[2]*/  float **out; // Output data, [neurons_in_layer[nl-1]][num_instances]

/*[3]*/  float **z; // [num_layers][neurons_per_layer[l]]
/*[3]*/  float **a; // [num_layers][neurons_per_layer[l]]
//------------------------------------------------------------
} DNN_REC_TYPE;
#endif // _DNN_TYPES_H
