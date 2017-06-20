#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "../gen_src/_seq_I4.c"

int main() {
  int n = 10;
  int32_t *X = (int32_t *) malloc(n*sizeof(int32_t));
  SEQ_I4_REC_TYPE args;
  args.start = 1;
  args.by = 3;

  int status = 0;
  
  status = seq_I4(X, n, &args, true);

  for(int i = 0; i < n; i += 1 ) {
    printf("%d ", X[i]);
  }
  printf("\n");

  return status;

}




