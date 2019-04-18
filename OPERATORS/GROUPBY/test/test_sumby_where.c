#include "q_incs.h"
#include "_sumby_where_I4_I1_I8.h"

int main(void)
{
  int status = 0;
  int nX = 105, nZ = 10;
  int32_t val_fld[nX];
  int64_t out_fld[nX];
  int8_t  grpby_fld[nZ];
  uint64_t cfld[nX/64 + 1];

  bool is_safe = 0;
  // Set X values correctly
  if ( nX > 127 ) { go_BYE(-1); }
  for ( int i = 0; i < nX; i++ ) { val_fld[i] = (i+1)*100; }
  for ( int i = 0; i < nX; i++ ) { out_fld[i] = INT_MAX; }
  for ( int i = 0; i < nZ; i++ ) { grpby_fld[i] = i; }
  cfld[0] = ~0; // First 64 values are to be included
  cfld[1] = 0;  // Next 64 valyues are to be excluded
  status = sumby_where_I4_I1_I8(
      val_fld, nX, 
      grpby_fld, nZ, 
      cfld, out_fld, is_safe); cBYE(status);
BYE:
  return status;
}
