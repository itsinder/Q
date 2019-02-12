#ifndef __DNN_TYPES_H
#define __DNN_TYPES_H

typedef enum act_fn_type { 
  undef_act_fn, RELU, SIGMOID, SOFT_MAX, TANH, LEAKY_RELU
} ACT_FN_TYPE;

typedef struct _dnn_rec_type {
  int bsz; // batch size
  int nl; // num layers
  int *npl;  // neurons per layer  [num_layers]
  ACT_FN_TYPE  *A; // activation_function[num_layers] 
  /* A[0] = undef_act_fn */
  float **in; // Input data, [neurons_in_layer[0]][num_instances]
  int num_instances; // 
  float **out; // Output data, [neurons_in_layer[nl-1]][num_instances]
  float ***W; // weights, [num_layers][][] 
  float **b; // bias, [num_layers] [neurons_per_layer[l]]
  /* W[0] = NULL
   * W[i] = [neurons_in_layer[i-1]][neurons_in_layer[i]]
   * b[0] = NULL
   * W[i] = [neurons_in_layer[i]]
   * */
//------------------------------------------------------------
} DNN_REC_TYPE;
#endif // _DNN_TYPES_H
