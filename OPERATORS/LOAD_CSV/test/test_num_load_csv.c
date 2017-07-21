#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include "num_load_csv.h"
//#include "_rand_file_name.h"

int
main(void) {
  int status = 0;
#ifdef XXX
  const char *infile = "../../../DATA_SETS/MNIST/mnist/train_data.csv";
  uint32_t nC = 1024;
  const char *fldtypes[nC];
  for ( uint32_t i = 0; i < nC; i++ ) {
    fldtypes[i] = "I4";
  }

  int bufsz = 32; // _f1024 is 6 chars and then one space for null char
  const char **outfiles = NULL;
  outfiles = malloc(nC * sizeof(char *));
  for ( uint32_t i = 0; i < nC; i++ ) {
    outfiles[i] = malloc(bufsz * sizeof(char));
    sprintf(outfiles[i], "_test_files/_f%d.bin", i+1);
  }

  uint64_t nR = NULL;
  status = num_load_csv(infile, nC, &nR, outfiles, fldtypes, false);
#endif

  const char *infile = "small_with_header_and_nils.csv";
  uint32_t nC = 3;
  const char *fldtypes[nC];
  fldtypes[0] = "I4";
  fldtypes[1] = "F4";
  fldtypes[2] = "I4";

  const char *outfiles[nC];
  outfiles[0] = "_a";
  outfiles[1] = "_b";
  outfiles[2] = "_c";

  const char *nil_files[nC];
  nil_files[0] = "_nil_a";
  nil_files[1] = "_nil_b";
  nil_files[2] = "_nil_c";

  bool is_load[nC];
  is_load[0] = false;
  is_load[1] = true;
  is_load[2] = true;


  uint64_t nR = NULL;

  status = num_load_csv(infile, nC, &nR, outfiles, fldtypes, true, is_load, nil_files);

BYE:
  /*for ( uint32_t i = 0; i < nC; i++ ) {
    free_if_non_null(outfiles[i]);
  }
  free_if_non_null(outfiles);
  */
  return status;
}
