#ifndef __SCALAR_H
#define __SCALAR_H
typedef enum _qtype_type { undef, I1, I2, I4, I8, F4, F8} QTYPE;

typedef union _cdata_type {
  int8_t  valI1;
  int16_t valI2;
  int32_t valI4;
  int64_t valI8;
  float   valF4;
  double  valF8;
} CDATA_TYPE;

typedef struct _sclr_rec_type {
  char field_type[8];
  CDATA_TYPE cdata;
} SCLR_REC_TYPE;
#endif
