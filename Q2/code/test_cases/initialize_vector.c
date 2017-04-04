
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
#include <string.h>

int initialize_vector_B1(unsigned char* x, int i){
    return x[i/8] |= 1 << (i % 8);
}
void initialize_vector_I1( int8_t *vec, int i, int8_t val)
{
  vec[i] = val;
}
void initialize_vector_I2( int16_t *vec, int i, int16_t val)
{
  vec[i] = val;
}
void initialize_vector_I4( int32_t *vec, int i, int32_t val)
{
  vec[i] = val;
}
void initialize_vector_I8( int64_t *vec, int i, int64_t val)
{
  vec[i] = val;
}
void initialize_vector_F4( float *vec, int i, float val)
{
  vec[i] = val;
}
void initialize_vector_F8( double *vec, int i, double val)
{
  vec[i] = val;
}
void initialize_vector_SV( int32_t *vec, int i, int32_t val)
{
  vec[i] = val;
}
void initialize_vector_SC(
      char * const X,
      char *out,
      int sz_out /* size of buffer. needs to end with nullc */
      )

{
  int i;
  for(i=0;i<sz_out;i++)
   out[i] = X[i];
}
