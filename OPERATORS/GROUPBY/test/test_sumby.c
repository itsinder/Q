#include "q_incs.h"
#include "_sumby_I4_I1_I8.h"

int main(void)
{
  int status = 0;
  int nR_in = 105, nR_out = 10;
  int32_t val_fld[nR_in];
  int8_t grpby_fld[nR_in];
  int64_t  out_fld[nR_out];
  uint64_t cfld[nR_in/64 + 1];

  bool is_safe = false;
  if ( nR_in > 127 ) { go_BYE(-1); }
  for ( int i = 0; i < nR_in; i++ ) { val_fld[i] = (i+1)*100; }
  // Make sure values of grpby_fld do not exceed nR_out
  int ctr = 0;
  for ( int i = 0; i < nR_in; i++ ) { 
    grpby_fld[i] = ctr++; 
    if ( ctr == nR_out ) { ctr = 0; }
  }
  for ( int i = 0; i < nR_out; i++ ) { out_fld[i] = LLONG_MAX; }
  for ( int iter = 0; iter < 2; iter++ ) { 
    switch ( iter ) { 
      case 0 : 
        cfld[0] = ~0; // First 64 values are to be included
        cfld[1] = ~0;  // Next 64 valyues are to be excluded
        break;
      case 1 : 
        cfld[0] = 0; // First 64 values are to be included
        cfld[1] = 0;  // Next 64 valyues are to be excluded
        break;
      default : 
        go_BYE(-1);
        break;
    }

    status = sumby_I4_I1_I8(
        val_fld, nR_in, grpby_fld, 
        out_fld, nR_out, 
        cfld, is_safe); 
    cBYE(status);
    int64_t sum1 = 0, sum2 = 0;
    for ( int i = 0; i < nR_out; i++ ) { 
      // fprintf(stderr, "%d: %lld \n", i, (long long int)out_fld[i]);
      sum1 += out_fld[i];
    }
    for ( int i = 0; i < nR_in; i++ ) { 
      sum2 += val_fld[i];
    }
    switch ( iter ) { 
      case 0 : 
        if ( sum1 != sum2 ) { go_BYE(-1); }
        break;
      case 1 : 
        if ( sum1 != 0 ) { go_BYE(-1); }
        break;
      default : 
        go_BYE(-1);
        break;
    }
  }
  // TODO P3: Can write better tests than these. This are very basic
BYE:
  return status;
}
