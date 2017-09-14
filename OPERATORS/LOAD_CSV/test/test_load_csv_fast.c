#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "load_csv_fast.h"
#include "q_incs.h"

#define MAX_NUM_COLS 2048
// _f1024 is 6 chars and then one space for null char
#define MAX_LEN_FILE_NAME 32
int
main(void) {
  int status = 0;
  char infile[256];
  char *fldtypes[MAX_NUM_COLS];
  char *outfiles[MAX_NUM_COLS];
  char *nil_files[MAX_NUM_COLS];
  uint32_t nC;
  uint64_t nR = 0;
  bool is_hdr = false;
  bool has_nulls[MAX_NUM_COLS];
  bool is_load[MAX_NUM_COLS];

  for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
    fldtypes[i]  = NULL;
    outfiles[i]  = NULL;
    nil_files[i] = NULL;
  }
  for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
    fldtypes[i]  = malloc(4 * sizeof(char));
    outfiles[i]  = malloc(MAX_LEN_FILE_NAME * sizeof(char));
    nil_files[i] = malloc(MAX_LEN_FILE_NAME * sizeof(char));
  }

  // We iterate over 5 data sets 
  for ( int data_set_id = 0; data_set_id < 5; data_set_id++ ) {
    for ( uint32_t i = 0; i < nC; i++ ) {
      memset(fldtypes[i],'\0', 4);
      memset(outfiles[i], '\0', MAX_LEN_FILE_NAME);
      memset(nil_files[i], '\0', MAX_LEN_FILE_NAME);
    }
    int j;
    memset(infile, '\0', MAX_LEN_FILE_NAME);
    switch ( data_set_id ) {
      case 0 : 
        is_hdr = false;
        nC = 1024;
        strcpy(infile, "./mnist/train_data.csv");

        j = 0;
        for ( uint32_t i = 0; i < nC; i++ ) {
          switch ( j ) { 
            case 0 : strcpy(fldtypes[i], "I2"); break;
            case 1 : strcpy(fldtypes[i], "I2"); break;
            case 2 : strcpy(fldtypes[i], "I2"); break;
            case 3 : strcpy(fldtypes[i], "I2"); break;
            case 4 : strcpy(fldtypes[i], "I2"); break;
            default : go_BYE(-1); break;
          }
          j++; if ( j == 5 ) { j = 0; }
        }

        j = 0;
        for ( uint32_t i = 0; i < nC; i++ ) {
          switch ( j ) { 
            case 0 : is_load[i] = true; has_nulls[i] = true; break;
            case 1 : is_load[i] = true; has_nulls[i] = false; break;
            case 2 : is_load[i] = false; has_nulls[i] = true; break;
            case 3 : is_load[i] = false; has_nulls[i] = false; break;
            default : go_BYE(-1); break;
          }
          j++; if ( j == 4 ) { j = 0; } 
        }
        // Here we create names for data files and nil files 
        for ( uint32_t i = 0; i < nC; i++ ) {
          sprintf(outfiles[i], "_test_files/_f%d.bin", i+1);
          sprintf(nil_files[i], "_test_files/_nil_f%d.bin", i+1);
        }
        break;
      case 1 : 
        is_hdr = true;
        nC = 3;
        strcpy(infile, "small_with_header.csv");
        strcpy(fldtypes[0], "I4");
        strcpy(fldtypes[1], "F4");
        strcpy(fldtypes[2], "I4");

        strcpy(outfiles[0], "_col_ds1_0_I4");
        strcpy(outfiles[1], "_col_ds1_1_F4");
        strcpy(outfiles[2], "_col_ds1_2_I4");

        is_load[0] = true;
        is_load[1] = true;
        is_load[2] = true;

        has_nulls[0] = false;
        has_nulls[1] = false;
        has_nulls[2] = false;
        break;
      case 2 : 
        is_hdr = true;
        nC = 3;
        strcpy(infile, "small_with_header_and_nils.csv");
        strcpy(fldtypes[0], "I4");
        strcpy(fldtypes[1], "F4");
        strcpy(fldtypes[2], "I4");

        strcpy(outfiles[0], "_col_ds2_0_I4");
        strcpy(outfiles[1], "_col_ds2_1_F4");
        strcpy(outfiles[2], "_col_ds2_2_I4");

        strcpy(nil_files[0], "_nn_ds2_col_0_I4");
        strcpy(nil_files[1], "_nn_ds2_col_1_F4");
        strcpy(nil_files[2], "_nn_ds2_col_2_I4");

        is_load[0] = true;
        is_load[1] = true;
        is_load[2] = false;

        has_nulls[0] = true;
        has_nulls[1] = true;
        has_nulls[2] = false;
        break;
      case 3 : 
        is_hdr = true;
        nC = 5;
        strcpy(infile, "iris_with_nils.csv");
        strcpy(fldtypes[0], "I4");
        strcpy(fldtypes[1], "F4");
        strcpy(fldtypes[2], "F4");
        strcpy(fldtypes[3], "F4");
        strcpy(fldtypes[4], "F4");

        strcpy(outfiles[0], "_nothing");
        strcpy(outfiles[1], "_sepal_length");
        strcpy(outfiles[2], "_sepal_width");
        strcpy(outfiles[3], "_petal_length");
        strcpy(outfiles[4], "_petal_width");

        strcpy(nil_files[0], "_nil_nothing");
        strcpy(nil_files[1], "_nil_sl");
        strcpy(nil_files[2], "_nil_sw");
        strcpy(nil_files[3], "_nil_pl");
        strcpy(nil_files[4], "_nil_pw");

        is_load[0] = false;
        is_load[1] = true;
        is_load[2] = true;
        is_load[3] = true;
        is_load[4] = true;

        has_nulls[0] = false;
        has_nulls[1] = false;
        has_nulls[2] = true; 
        has_nulls[3] = false;
        has_nulls[4] = true;

        break;
      case 4 : 
        is_hdr = false;
        nC = 2;
        strcpy(infile, "I1_I2_input_csv.csv");
        strcpy(fldtypes[0], "I1");
        strcpy(fldtypes[1], "I2");

        strcpy(outfiles[0], "_col_ds4_0_I1");
        strcpy(outfiles[1], "_col_ds4_1_I2");

        is_load[0] = true;
        is_load[1] = true;

        has_nulls[0] = true;
        has_nulls[1] = true;
                
        
        strcpy(nil_files[0], "_nil_1");
        strcpy(nil_files[1], "_nil_2");

        break;

      default : 
        nC = 0;
        go_BYE(-1);
        break;
    }
    status = load_csv_fast(infile, nC, &nR, outfiles, fldtypes, 
        is_hdr, is_load, has_nulls, nil_files);
    cBYE(status);
    // POST CHECKS : TODO Do more testing in all cases below
    // I have done a few checks
    switch ( data_set_id ) { 
      case 0 : 
        for ( uint32_t i = 0; i < nC; i++ ) {
          FILE *fp = NULL;
          fp = fopen(nil_files[i], "r");
          if ( fp != NULL ) { go_BYE(-1); }
        }
        break;
      case 1 : 
        for ( uint32_t i = 0; i < nC; i++ ) {
          FILE *fp = NULL;
          if ( ( nil_files[i] == NULL ) || ( nil_files[i][0] == '\0' ) ) {
            continue;
          }
          fp = fopen(nil_files[i], "r");
          if ( fp != NULL ) { go_BYE(-1); }
        }
        break;
      case 2 : 
        // TODO do some testing
        break;
      case 3 : 
        // TODO do some testing
        for ( uint32_t i = 0; i < nC; i++ ) {
          FILE *fp = NULL;
          // for col 2 and 4 nulls are present in data 
          // so nil file ptr can't be null
          // and for other cols has_null is false
          // so nil file ptr should be null
          if (i == 2 || i == 4)
          {
            fp = fopen(nil_files[i], "r");
            if ( fp == NULL ) { go_BYE(-1); } // if nil_file_ptr is null error out
          }
          else
          {
            fp = fopen(nil_files[i], "r");
            if ( fp != NULL ) { go_BYE(-1); } // if nil_file_ptr is not null error out
          }
        }
        break;
      case 4 : 
        for ( uint32_t i = 0; i < nC; i++ ) {
          FILE *fp = NULL;
          fp = fopen(nil_files[i], "r");
          if ( fp != NULL ) { go_BYE(-1); }
        }
        break;
        
      default : 
        go_BYE(-1); 
        break;

    }

    fprintf(stderr, "Loaded data set %d \n", data_set_id);
  }

BYE:
  for ( uint32_t i = 0; i < nC; i++ ) {
    free_if_non_null(outfiles[i]);
    free_if_non_null(nil_files[i]);
  }

  return status;
}
