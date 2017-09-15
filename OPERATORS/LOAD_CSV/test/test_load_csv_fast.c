#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "load_csv_fast.h"
#include "q_incs.h"
#include "_mmap.h"

#define MAX_NUM_COLS 2048
// _f1024 is 6 chars and then one space for null char
#define MAX_LEN_FILE_NAME 32
int
main(
  int argc,
  char **argv
    ) 
{
  int status = 0;
  char infile[256];
  char *fldtypes[MAX_NUM_COLS];
  char **out_files = NULL;
  char **nil_files = NULL;
  int sz_str_for_lua = 0;
  char *str_for_lua = NULL;
  uint32_t nC;
  uint64_t nR = 0;
  bool is_hdr = false;
  bool has_nulls[MAX_NUM_COLS];
  bool is_load[MAX_NUM_COLS];
  uint64_t num_nulls[MAX_NUM_COLS];

  if ( argc == 2 ) {
    sz_str_for_lua = atoi(argv[1]);
  }
  if ( sz_str_for_lua > 0 ) { 
    str_for_lua = malloc(sz_str_for_lua);
    return_if_malloc_failed(str_for_lua);
  }
  for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
    fldtypes[i]  = NULL;
  }
  for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
    fldtypes[i]  = malloc(4 * sizeof(char));
  }

  // We iterate over 5 data sets 
  for ( int data_set_id = 0; data_set_id < 5; data_set_id++ ) {
    for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
      memset(fldtypes[i],'\0', 4);
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
        break;
      case 1 : 
        is_hdr = true;
        nC = 3;
        strcpy(infile, "small_with_header.csv");
        strcpy(fldtypes[0], "I4");
        strcpy(fldtypes[1], "F4");
        strcpy(fldtypes[2], "I4");

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
        strcpy(infile, "I1_I2_input.csv");
        strcpy(fldtypes[0], "I1");
        strcpy(fldtypes[1], "I2");

        is_load[0] = true;
        is_load[1] = true;

        has_nulls[0] = true;
        has_nulls[1] = true;
                
        break;

      default : 
        nC = 0;
        go_BYE(-1);
        break;
    }
    status = load_csv_fast("/tmp/", infile, nC, &nR, fldtypes, 
        is_hdr, is_load, has_nulls, num_nulls, &out_files, &nil_files,
        str_for_lua, sz_str_for_lua);
    cBYE(status);
    // POST CHECKS : TODO Do more testing in all cases below
    // I have done a few checks
    switch ( data_set_id ) { 
      case 0 : 
        if ( sz_str_for_lua > 0 ) { 
        }
        else {
          /* Verify that there are no nil files */
          for ( uint32_t i = 0; i < nC; i++ ) {
            if ( nil_files[i] != NULL ) { go_BYE(-1); }
          }
        }
        break;
      case 1 : 
        if ( sz_str_for_lua > 0 ) { 
          fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
          /* Verify that there are no nil files */
          for ( uint32_t i = 0; i < nC; i++ ) {
            if ( nil_files[i] != NULL ) { go_BYE(-1); }
          }
        }
        break;
      case 2 : 
        if ( sz_str_for_lua > 0 ) { 
          fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
        // TODO do some testing
        }
        break;
      case 3 : 
        if ( sz_str_for_lua > 0 ) { 
          fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
          for ( uint32_t i = 0; i < nC; i++ ) {
            // nil file should exist for col 2, 4
            if ( (i == 2 ) || (i == 4) ) { 
              char *X = NULL; size_t nX = 0;
              if ( nil_files[i] == NULL ) { go_BYE(-1); }
              status = rs_mmap(nil_files[i], &X, &nX, 0); cBYE(status);
              if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
              rs_munmap(X, nX);
            }
            else {
              if ( nil_files[i] != NULL ) { go_BYE(-1); }
            }
          }
        }
        break;
      case 4 : 
        if ( sz_str_for_lua > 0 ) { 
          fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
          for ( uint32_t i = 0; i < nC; i++ ) {
            FILE *fp = NULL;
            fp = fopen(nil_files[i], "r");
            if ( fp != NULL ) { go_BYE(-1); }
          }
        }
        break;
        
      default : 
        go_BYE(-1); 
        break;

    }
    if ( out_files != NULL ) { 
      for ( uint32_t i = 0; i < nC; i++ ) {
        free_if_non_null(out_files[i]);
      }
    }
    if ( nil_files != NULL ) { 
      for ( uint32_t i = 0; i < nC; i++ ) {
        free_if_non_null(nil_files[i]);
      }
    }

    fprintf(stderr, "Loaded data set %d \n", data_set_id);
  }

BYE:
  return status;
}
