#include <stdio.h>
#include <stdint.h>

int
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
