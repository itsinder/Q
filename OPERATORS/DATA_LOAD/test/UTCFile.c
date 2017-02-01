#include<stdint.h>
#include<stdio.h>

void initialize( int32_t *a, int32_t *b, uint64_t n)
{
  int i;
  for (i = 1 ; i <= n ; i++)
  {
    a[i] = i;
    b[i] = i*i;
  }
}

int add_I4_I4_I4( int32_t *a, int32_t *b, uint64_t n, int32_t *c)
{
  int status = 0;
  int i;
  for ( i = 1; i <= n; i++ ) 
  {
    c[i] = a[i] + b[i];
  }
  return status;
}
