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
    const char **outfiles,
    const char **fldtypes,
    bool is_hdr,
    bool *is_load,
    const char **nil_files
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *mmap_file = NULL; //X
  size_t file_size = 0; //nX
  FILE **ofps = NULL;
  FILE **nofps = NULL;
  qtype_type *qtypes = NULL;
  uint64_t *nil_ctrs = NULL;

  //---------------------------------
  if ( ( infile == NULL ) || ( *infile == '\0' ) ) { go_BYE(-1); }
  if ( outfiles == NULL ) { go_BYE(-1); }
  if ( nC == 0 ) { go_BYE(-1); }
  if ( ptr_nR == NULL ) { go_BYE(-1); }
  //---------------------------------
  // allocate space and other resources

  nil_ctrs = malloc(nC * sizeof(uint64_t));
  return_if_malloc_failed(nil_ctrs);
  for(uint32_t i = 0; i < nC; i++ ) {
    nil_ctrs[i] = 0;
  }

  *ptr_nR = 0;
  // set up qtypes 
  qtypes = malloc(nC * sizeof(qtype_type));
  return_if_malloc_failed(qtypes);
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( !is_load[i] ) {
      qtypes[i] = undef;
      continue;
    }
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
  // malloc and open output file pointers and nil output file pointers
  ofps = malloc(nC * sizeof(FILE *));
  return_if_malloc_failed(ofps);
  nofps = malloc(nC * sizeof(FILE *));
  return_if_malloc_failed(nofps);
  for ( uint32_t i = 0; i < nC; i++ ) {
    ofps[i] = NULL;
    nofps[i] = NULL;
  }
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( !is_load[i] ) {
      continue;
    }
    if ( outfiles[i] != '\0' ) {
      ofps[i] = fopen(outfiles[i], "wb");
      return_if_fopen_failed(ofps[i], outfiles[i], "wb");
    } 
    else {
      cBYE(-1)
    }
    if ( nil_files[i] != '\0' ) {
      nofps[i] = fopen(nil_files[i], "wb");
      return_if_fopen_failed(nofps[i], nil_files[i], "wb");
    } 
    else {
      cBYE(-1)
    }
  }
  //---------------------------------

  //mmap the file
  status = rs_mmap(infile, &mmap_file, &file_size, false); //false b/c not writing to file
  cBYE(status);
  if ( ( mmap_file == NULL ) || ( file_size == 0 ) )  { go_BYE(-1); }

  int8_t tempI1; int16_t tempI2; int32_t tempI4; int64_t tempI8; float tempF4; double tempF8;

  size_t prev_xidx = 0;
  int8_t nil = 0;
  size_t xidx = 0;
  uint64_t row_ctr = 0;
  uint64_t col_ctr = 0;
  bool is_last_col;
  //read from the input file and write to the output file
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
    prev_xidx = xidx;
    xidx = get_cell(mmap_file, file_size, xidx, is_last_col, buf, bufsz);
    if ( (xidx - prev_xidx) == 1 ) { //only one character consumed (the comma or new line character)
      nil_ctrs[col_ctr] += 1;
      nil = 1;
    }
    else {
      nil = 0;
    }
    fprintf(stderr, "%llu, %llu, %llu, %s \n", row_ctr, col_ctr, xidx, buf);
    if ( xidx == 0 ) { go_BYE(-1); } //means the file is empty
    //row_ctr == 0 means we are reading the first line which is the header
    if ( (( is_hdr ) && ( row_ctr == 0 )) || (!is_load[col_ctr]) ) { 
      if ( col_ctr == nC - 1 ) {
        row_ctr = row_ctr + 1;
      }
      col_ctr = (col_ctr + 1) % nC;
      if ( xidx >= file_size ) { break; } // check == or >= 
      continue; 
    }
    //after a line has been read, increment the row count
    if ( col_ctr == nC-1 ) {
      row_ctr = row_ctr + 1;
    }
    fwrite(&nil, 1, sizeof(int8_t), nofps[col_ctr]);
    if ( nil == 1 ) {
      col_ctr = (col_ctr + 1) % nC;
      if ( xidx >= file_size ) { break; } // check == or >= 
      continue;
    }
    switch ( qtypes[col_ctr] ) {
      case I1:
        status = txt_to_I1(buf, &tempI1); cBYE(status);
        fwrite(&tempI1, 1, sizeof(int8_t), ofps[col_ctr]);
        //printf("I1\n");
        break;
      case I2:
        status = txt_to_I2(buf, &tempI2); cBYE(status);
        fwrite(&tempI1, 1, sizeof(int16_t), ofps[col_ctr]);
        //printf("I2");
        break;
      case I4:
        status = txt_to_I4(buf, &tempI4); cBYE(status);
        fwrite(&tempI4, 1, sizeof(int32_t), ofps[col_ctr]);
        printf("I4\n");
        break;
      case I8:
        status = txt_to_I8(buf, &tempI8); cBYE(status);
        fwrite(&tempI8, 1, sizeof(int64_t), ofps[col_ctr]);
        //printf("I8\n");
        break;
      case F4:
        status = txt_to_F4(buf, &tempF4); cBYE(status);
        fwrite(&tempF4, 1, sizeof(float), ofps[col_ctr]);
        printf("F4\n");
        break;
      case F8:
        status = txt_to_F8(buf, &tempF8); cBYE(status);
        fwrite(&tempF8, 1, sizeof(double), ofps[col_ctr]);
        //printf("F8\n");
        break;
      default:
        //should not come here
        go_BYE(-1);
        break;
    }
    /*this check needs to be done after the file has been written to because it
     * is possible that on the last get_cell, xidx is incremented to file_size
     * or greater, but the value from that last get_cell still needs to be
     * written to file*/
    if ( xidx >= file_size ) { break; } // check == or >= 
    col_ctr = (col_ctr + 1) % nC;
  }
  //want to exclude the header from the row count
  if ( is_hdr ) { row_ctr--; }
  //header row
  *ptr_nR = row_ctr;


BYE:
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( *outfiles[i] != '\0' ) {
      fclose_if_non_null(ofps[i]);
    }
    if ( *nil_files[i] != '\0' ) {
      fclose_if_non_null(nofps[i]);
    }
  }

  if ( ofps != NULL ) { 
    for  ( uint32_t i = 0; i < nC; i++ ) { 
      fclose_if_non_null(ofps[i]);
    }
  }

  if ( nofps != NULL ) { 
    for  ( uint32_t i = 0; i < nC; i++ ) { 
      fclose_if_non_null(nofps[i]);
    }
  }
  //delete nil_files with no nil elements
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( nil_ctrs[i] == 0 ) {
      status = remove(nil_files[i]);
      nil_files[i] = NULL;
      cBYE(status);
    }
  }

  rs_munmap(mmap_file, file_size);
  free_if_non_null(ofps);
  free_if_non_null(nofps);
  free_if_non_null(nil_ctrs);
  return status;
}
