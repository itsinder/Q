#ifndef __DNN_TYPES_H
#define __DNN_TYPES_H

typedef enum act_fn_type { 
  undef_act_fn, RELU, SIGMOID, SOFT_MAX, TANH, LEAKY_RELU
} ACT_FN_TYPE;

typedef struct _dnn_rec_type {
  int bsz; // batch size
  int nl; // num layers
  int *npl;  // neurons per layer 
  ACT_FN_TYPE  *A; // activation_function[num_layers] 
  float **X; // TODO NOT SURE  [neurons_in_layer[0]][num_instances]
  int num_instances; // TODO NOT SURE 
  float ***W; // [num_layers] 
  float **b; // [num_layers] [neurons_per_layer[l]]
  /* W[0] = NULL
   * W[i] = [neurons_in_layer[i-1]][neurons_in_layer[i]]
   * */
  float **B; // [num_layers] B[0] = 0 --> unused
//------------------------------------------------------------
} DNN_REC_TYPE;
#endif // _DNN_TYPES_H
