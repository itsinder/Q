/* START: Inputs */
int num_instances;
int num_epochs;
int batch_size;
int num_layers;
int *neurons_in_layer; 
float **X; // [neurons_in_layer[0]][num_instances]
/* STOP: Inputs */

float ***W;
W = (float ***)malloc(num_layers * sizeof(float **));
return_if_malloc_failed(W);
for ( int l = 1; l < num_layers; l++ ) {
  W[l] = malloc(neurons_in_layer[l-1]*neurons_in_layer[l]*sizeof(float));
  /* above is not quite correct. To be fixed */
}
//------------------------------------------------------------
float ***Y;
Y = (float ***)malloc(num_layers * sizeof(float **));
return_if_malloc_failed(Y);
for ( int l = 0; l < num_layers; l++ ) {
  Y[l] = malloc(neurons_in_layer[l] * sizeof(float *));
  return_if_malloc_failed(Y[l]);
  if ( l > 0 ) { 
    for ( m = 0; m < neurons_in_layer[l]; m++ ) { 
      Y[l][m] = malloc(batch_size * sizeof(float));
      return_if_malloc_failed(Y[l][m]);
    }
  }
}
//------------------------------------------------------------
for ( int i = 0; i < num_epochs; i++ ) { 
  int num_batches = num_instances / batch_size;
  if ( num_batches == 0 ) { num_batches++; }
  for ( int j = 0; j < num_batches; j++ ) { 
    int lb = j  * batch_size;
    int ub = lb + batch_size;
    if ( j == num_batches ) { ub = n; }
    int l_num_instances = ub - lb;
    for ( int l = 1; l < num_layers; l++ ) {
      if ( l == 1 )  {
        for ( int k = 0; k < num_neurons_in_layer[0]; k++ ) { 
          Y[k] = X[k] + lb;
        }
      }
    }
  }
}

