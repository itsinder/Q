#include<stdio.h>
#include<stdlib.h>
#include <inttypes.h>
#include "logit_I8.h"
#include "_get_time_usec.h"

int main() {
  int status = 0;
  int64_t *in_buf1;
  double *out_buf;
  int start, stop = 0;
  int num_elements = 10000000;

  // Allocate memory for in_buf1, in_buf2 & out_buf
  in_buf1 = malloc(num_elements * sizeof("int64_t"));
  out_buf = malloc(num_elements * sizeof("double"));

  // Initialize in_buf
  for ( int i = 0; i < num_elements; i++ ) {
    in_buf1[i] = 2;
    out_buf[i] = 0;
  }
  
  start = get_time_usec();
  for ( int i = 0; i < 100; i++) {
    status = logit_I8(in_buf1, NULL, num_elements, NULL, out_buf, NULL);
  }
  stop = get_time_usec();

  printf("logit execution time C = %d\n", stop-start);

  printf("Done\n");
  return status;
}