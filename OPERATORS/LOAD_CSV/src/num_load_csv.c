//START_INCLUDES
#include <stdio.h>
#include <stdbool.h>
#include "q_macros.h"
#include "_txt_to_I1.h"
#include "_txt_to_I2.h"
#include "_txt_to_I4.h"
#include "_txt_to_I8.h"
#include "_txt_to_F4.h"
#include "_txt_to_F8.h"
#include "_get_cell.h"
#include "_mmap.h"
//STOP_INCLUDES
#include "num_load_csv.h"

/*Given a csv file, this method will convert the file into nC binary files
 * where nC is the number of columns in the csv file and each file will
 * contain the contents of a column from the csv file*/

/*Steps:
 *1) call get cell
 *2) convert cell from string to C type using _txt_to_* methods
 *3) write binary returned from _txt_to_* method to file
 *4) return files
 */

typedef enum _qtype_type { undef, I1, I2, I4, I8, F4, F8 } qtype_type;
//START_FUNC_DECL
int
num_load_csv(
    char *infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    char **outfiles,
    char **fldtypes,
    bool is_hdr
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *mmap_file = NULL; //X
  size_t file_size = 0; //nX
  FILE **ofps = NULL;
  qtype_type *qtypes = NULL;

  //---------------------------------
  if ( ( infile == NULL ) || ( *infile == '\0' ) ) { go_BYE(-1); }
  if ( outfiles == NULL ) { go_BYE(-1); }
  if ( nC == 0 ) { go_BYE(-1); }
  if ( ptr_nR == NULL ) { go_BYE(-1); }
  //---------------------------------
  // allocate space and other resources
  *ptr_nR = 0;
  ofps = malloc(nC * sizeof(FILE *));
  return_if_malloc_failed(ofps);
  for ( uint32_t i = 0; i < nC; i++ ) {
    ofps[i] = NULL;
  }
  // set up qtypes 
  qtypes = malloc(nC * sizeof(qtype_type));
  return_if_malloc_failed(qtypes);
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( strcasecmp(fldtypes[i], "I1") == 0 ) {
      qtypes[i] = I1;
    }
    else if ( strcasecmp(fldtypes[i], "I2") == 0 ) {
      qtypes[i] = I2;
    }
    else if ( strcasecmp(fldtypes[i], "I4") == 0 ) {
      qtypes[i] = I4;
    }
    else if ( strcasecmp(fldtypes[i], "I8") == 0 ) {
      qtypes[i] = I8;
    }
    else if ( strcasecmp(fldtypes[i], "F4") == 0 ) {
      qtypes[i] = F4;
    }
    else if ( strcasecmp(fldtypes[i], "F8") == 0 ) {
      qtypes[i] = F8;
    }
    else { go_BYE(-1); }
  }
  // malloc and open output file pointers
  ofps = malloc(nC * sizeof(FILE *));
  return_if_malloc_failed(ofps);
  for ( uint32_t i = 0; i < nC; i++ ) {
    ofps[i] = NULL;
  }
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( outfiles[i] != '\0' ) {
      ofps[i] = fopen(outfiles[i], "wb");
      return_if_fopen_failed(ofps[i], outfiles[i], "wb");
    } 
    else {
      ofps[i] = stdout;
    }
  }
  //---------------------------------

  status = rs_mmap(infile, &mmap_file, &file_size, false); //false b/c not writing to file
  cBYE(status);
  if ( ( mmap_file == NULL ) || ( file_size == 0 ) )  { go_BYE(-1); }

  int8_t tempI1; int16_t tempI2; int32_t tempI4; int64_t tempI8; float tempF4; double tempF8;

  size_t xidx = 0;
  uint64_t row_ctr = 0;
  uint64_t col_ctr = 0;
  bool is_last_col;
  while ( true ) {
    size_t bufsz = 31;
    char buf[bufsz+1];
    memset(buf, '\0', bufsz+1);
    if ( col_ctr == nC-1 ) { 
      is_last_col = true;
    }
    else {
      is_last_col = false;
    }
    xidx = get_cell(mmap_file, file_size, xidx, is_last_col, buf, bufsz);
    fprintf(stderr, "%llu, %llu, %llu, %s \n", row_ctr, col_ctr, xidx, buf);
    if ( xidx == 0 ) { go_BYE(-1); }
    if ( col_ctr == nC-1 ) {
      row_ctr = row_ctr + 1;
    }
    if ( ( is_hdr ) && ( row_ctr == 1 ) ) { 
      continue; 
    }
    switch ( qtypes[col_ctr] ) {
      case I1:
        status = txt_to_I1(buf, &tempI1); cBYE(status);
        fwrite(&tempI1, 1, sizeof(int8_t), ofps[col_ctr]);
        printf("I1\n");
        break;
      case I2:
        status = txt_to_I2(buf, &tempI2); cBYE(status);
        fwrite(&tempI1, 1, sizeof(int16_t), ofps[col_ctr]);
        printf("I2\n");
        break;
      case I4:
        status = txt_to_I4(buf, &tempI4); cBYE(status);
        fwrite(&tempI4, 1, sizeof(int32_t), ofps[col_ctr]);
        printf("I4\n");
        break;
      case I8:
        status = txt_to_I8(buf, &tempI8); cBYE(status);
        fwrite(&tempI8, 1, sizeof(int64_t), ofps[col_ctr]);
        printf("I8\n");
        break;
      case F4:
        status = txt_to_F4(buf, &tempF4); cBYE(status);
        fwrite(&tempF4, 1, sizeof(float), ofps[col_ctr]);
        printf("F4\n");
        break;
      case F8:
        status = txt_to_F8(buf, &tempF8); cBYE(status);
        fwrite(&tempF8, 1, sizeof(double), ofps[col_ctr]);
        printf("F8\n");
        break;
      default:
        go_BYE(-1);
        break;
    }
    if ( xidx >= file_size ) { break; } // check == or >= 
    col_ctr = (col_ctr + 1) % nC;
  }
  if ( is_hdr ) { row_ctr--; }
  *ptr_nR = row_ctr;

BYE:
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( *outfiles[i] != '\0' ) {
      fclose_if_non_null(ofps[i]);
    }
  }
  if ( ofps != NULL ) { 
    for  ( uint32_t i = 0; i < nC; i++ ) { 
      fclose_if_non_null(ofps[i]);
    }
  }
  rs_munmap(mmap_file, file_size);
  free_if_non_null(ofps);
  return status;
}
