#include <stdio.h>
#include <stdint.h>
//#include "convert_I2_I4.h"

int8_t
convert_I2_I4(
  int16_t in,
  int32_t *out
  )

{
  int status = 0;
  int32_t outv = (int32_t) in;
  *out = outv;
  return status;
}


int main()
{
  int status = 0;
  int16_t in = 1345;
  int32_t out;
  status = convert_I2_I4(in, &out);
  printf("Output is %d, Status is %d\n", out, status);
  return status;
}
