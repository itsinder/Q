#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include "q_macros.h"
#include "_mix_UI8.h"
#include "_rand_file_name.h"
#include "_buf_to_file.h"

#define M 128
#define N 65536
int
main()
{
  int status = 0;
  char X[32];
  int Y[N];
  for ( int i = 0; i  < N; i++ ) { 
    Y[i] = i+1;
  }
  for ( int i = 0; i < 65536; i++ ) { 
    status = rand_file_name(X, 32); cBYE(status);
    // fprintf(stderr, "i = %d, X = %s \n", i, X);
    status = buf_to_file((const char *)Y, sizeof(int), N, X); cBYE(status);
  }
BYE:
  return status;
}
