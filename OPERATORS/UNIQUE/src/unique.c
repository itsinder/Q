#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>

int sort_elements(int *arr, int size) {
  int status = 0;
  int val;
  for ( int i = 0; i < ( size - 1 ); i++ ) {
    for ( int j = i + 1; j < size; j ++ ) {
      if ( arr[i] > arr[j] ) {
        val = arr[i];
        arr[i] = arr[j];
        arr[j] = val;
      }
    }
  }
  return status;
}

int unique(int *in_buf, int in_size, int *out_buf, int out_size, int *num_in_out) {
  int status = 0;
  int out_num = 0;
  if ( out_buf == NULL ) { return -1; }
  for ( int i = 0; i < out_size; i++ ) {
    out_buf[i] = 0;
  }
  *num_in_out = 0;
  status = sort_elements(in_buf, in_size);
  for ( int i = 0; i < in_size; i++ ) {
    if ( in_buf[i] != in_buf[i+1] ) {
      out_buf[out_num++] = in_buf[i];
    }
  }
  *num_in_out = out_num;
  return status;
}

int main() {
  int status = 0;
  int size = 10;
  int *in_buf, *out_buf, *num_in_out;

  // Allocate memory for in_buf & out_buf
  in_buf = malloc(size * sizeof("int"));
  out_buf = malloc(size * sizeof("int"));
  num_in_out = malloc(sizeof("int"));

  // Initialize in_buf
  printf("Input buffer is\n");
  for ( int i = 0; i < size; i++ ) {
    in_buf[i] = i % 3;
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
