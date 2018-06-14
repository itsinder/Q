#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>
#include<inttypes.h>

int unique(int32_t *in_buf, int in_size, int32_t *out_buf, int out_size, int *num_in_out) {
  int status = 0;
  int out_num = 0;
  if ( out_buf == NULL ) { return -1; }
  for ( int i = 0; i < out_size; i++ ) {
    out_buf[i] = 0;
  }
  *num_in_out = 0;
  for ( int i = 0; i < (in_size - 1); i++ ) {
    if ( in_buf[i] != in_buf[i+1] ) {
      out_buf[out_num++] = in_buf[i];
    }
  }
  // Include last element
  out_buf[out_num++] = in_buf[in_size-1];
  *num_in_out = out_num;
  return status;
}

int main() {
  int status = 0;
  int size = 10;
  int32_t *in_buf, *out_buf;
  int *num_in_out;

  // Allocate memory for in_buf & out_buf
  in_buf = malloc(size * sizeof("int32_t"));
  out_buf = malloc(size * sizeof("int32_t"));
  num_in_out = malloc(sizeof("int"));

  // Initialize in_buf
  printf("Input buffer is\n");
  for ( int i = 0; i < size; i++ ) {
    in_buf[i] = i+1;
    if ( i == 4 ) {
      in_buf[i] = 4;
    }
    else if ( i == 9 ) {
      in_buf[i] = 9;
    }
    printf("%d\n", in_buf[i]);
  }

  // Call to unique
  status = unique(in_buf, size, out_buf, size, num_in_out);

  printf("Unique elements in out_buf = %d\n", *num_in_out);
  for ( int i = 0; i < *num_in_out; i++ ) {
    printf("%d\n", out_buf[i]);
  }
  return status;
}
