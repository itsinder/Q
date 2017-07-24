#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include "load_csv_fast.h"

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
  status = load_csv_fast(infile, nC, &nR, outfiles, fldtypes, false);

  // const char *infile = "small_with_header.csv";
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
  is_load[0] = true;
  is_load[1] = true;
  is_load[2] = false;

  bool has_nulls[nC];
  has_nulls[0] = true;
  has_nulls[1] = true;
  has_nulls[2] = false;

  uint64_t nR = NULL;

  // status = num_load_csv(infile, nC, &nR, outfiles, fldtypes, true, is_load, nil_files);
  status = load_csv_fast(infile, nC, &nR, outfiles, fldtypes, true, is_load, has_nulls,
      nil_files);
#endif
  const char *infile = "iris.csv";
  uint32_t nC = 5;
  const char *fldtypes[nC];
  fldtypes[0] = "I4";
  fldtypes[1] = "F4";
  fldtypes[2] = "F4";
  fldtypes[3] = "F4";
  fldtypes[4] = "F4";

  const char *outfiles[nC];
  outfiles[0] = "_nothing";
  outfiles[1] = "_sepal_length";
  outfiles[2] = "_sepal_width";
  outfiles[3] = "_petal_length";
  outfiles[4] = "_petal_width";

  const char *nil_files[nC];
  nil_files[0] = "_nil_nothing";
  nil_files[1] = "_nil_sl";
  nil_files[2] = "_nil_sw";
  nil_files[3] = "_nil_pl";
  nil_files[4] = "_nil_pw";

  bool is_load[nC];
  is_load[0] = false;
  is_load[1] = true;
  is_load[2] = true;
  is_load[3] = true;
  is_load[4] = true;

  bool has_nulls[nC];
  has_nulls[0] = false;
  has_nulls[1] = false;
  has_nulls[2] = false;
  has_nulls[3] = false;
  has_nulls[4] = false;

  uint64_t nR = NULL;

  status = load_csv_fast(infile, nC, &nR, outfiles, fldtypes, true, is_load, has_nulls, nil_files);

BYE:
  /*for ( uint32_t i = 0; i < nC; i++ ) {
    free_if_non_null(outfiles[i]);
  }
  free_if_non_null(outfiles);
  */
  return status;
}
