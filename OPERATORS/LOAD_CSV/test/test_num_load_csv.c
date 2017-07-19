#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include "num_load_csv.h"

int
main(void) {
  int status = 0;
  const char *infile = "small_with_header.csv";
  const char *fldtypes[3];
  fldtypes[0] = "I8";
  fldtypes[1] = "F4";
  fldtypes[2] = "I4";

  const char *outfiles[3];
  outfiles[0] = "a";
  outfiles[1] = "b";
  outfiles[2] = "c";

  uint32_t nC = 3;
  uint64_t nR = NULL;

  status = num_load_csv(infile, nC, &nR, outfiles, fldtypes, true);


BYE:
  return status;
}
