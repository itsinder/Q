//START_INCLUDES
#include "q_incs.h"
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
#include "load_csv_fast.h"


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
load_csv_fast(
    const char * const infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    char **outfiles,
    char **fldtypes,
    bool is_hdr,
    bool *is_load,
    bool *has_nulls,
    char **nil_files//, TODO TODO TODO
    //uint64_t *ptr_nil_ctrs
    )
//STOP_FUNC_DECL
{
  int status = 0, bak_status = 0;
  char *mmap_file = NULL; //X
  size_t file_size = 0; //nX
  FILE **ofps = NULL;
  FILE **nofps = NULL;
  qtype_type *qtypes = NULL;
  uint64_t *nil_ctrs = NULL;
  uint64_t *nn_buf = NULL;

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

  nn_buf = malloc(nC * sizeof(uint64_t));
  return_if_malloc_failed(nn_buf);
  for(uint32_t i = 0; i < nC; i++ ) {
    nn_buf[i] = 0;
  }

  *ptr_nR = 0;
  // set up qtypes  -- convert from strings to enum
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
  // malloc output file pointers and nil output file pointers
  ofps = malloc(nC * sizeof(FILE *));
  return_if_malloc_failed(ofps);
  nofps = malloc(nC * sizeof(FILE *));
  return_if_malloc_failed(nofps);
  for ( uint32_t i = 0; i < nC; i++ ) {
    ofps[i] = NULL;
    nofps[i] = NULL;
  }
  // fopen output file pointers and nil output file pointers
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( !is_load[i] ) {
      continue;
    }
    if ( ( outfiles[i] == NULL ) || ( outfiles[i][0] == '\0' ) ) { 
      go_BYE(-1);
    }
    ofps[i] = fopen(outfiles[i], "wb");
    return_if_fopen_failed(ofps[i], outfiles[i], "wb");

    if ( has_nulls[i] ) { 
      if ( ( nil_files[i] == NULL ) || ( nil_files[i][0] == '\0' ) ) { 
        go_BYE(-1);
      }
      nofps[i] = fopen(nil_files[i], "wb");
      return_if_fopen_failed(nofps[i], nil_files[i], "wb");
    } 
  }
  //---------------------------------

  //mmap the file
  status = rs_mmap(infile, &mmap_file, &file_size, false); //false b/c not writing to file
  cBYE(status);
  if ( ( mmap_file == NULL ) || ( file_size == 0 ) )  { go_BYE(-1); }

  int8_t tempI1; int16_t tempI2; int32_t tempI4; int64_t tempI8; float tempF4; double tempF8;

  size_t xidx = 0;
  uint64_t row_ctr = 0;
  uint32_t col_ctr = 0;
  bool is_last_col;
  char null_val[8];
  memset(null_val, '\0', 8); // we write 0 when value is null
#define BUFSZ 31
  char buf[BUFSZ+1];
  bool is_val_null;
  //read from the input file and write to the output file

  while ( true ) {
    memset(buf, '\0', BUFSZ+1);

    // Decide whether this is the last column on the row. Needed by get_cell
    if ( col_ctr == nC-1 ) { 
      is_last_col = true;
    }
    else {
      is_last_col = false;
    }

    xidx = get_cell(mmap_file, file_size, xidx, is_last_col, buf, BUFSZ);
    if ( xidx == 0 ) { go_BYE(-1); } //means the file is empty or some error
    if ( xidx > file_size ) { break; } // check == or >= 

    //fprintf(stderr, "%llu, %u, %llu, %s \n", 
     //   (unsigned long long)row_ctr, col_ctr, 
     //   (unsigned long long)xidx, buf);

    // Deal with header line 
    //row_ctr == 0 means we are reading the first line which is the header
    if ( is_hdr ) { 
      if ( row_ctr != 0 ) { go_BYE(-1); }
      col_ctr++;
      if ( is_last_col ) {
        col_ctr = 0;
        is_hdr = false;
      }
      if ( xidx == file_size ) { break; } // check == or >= 
      continue; 
    }
    // If this column is not to be loaded then continue 
    if ( !is_load[col_ctr] ) {
      col_ctr++;
      if ( col_ctr == nC ) { 
        col_ctr = 0;
        row_ctr++;
      }
      if ( xidx == file_size ) { break; } // check == or >= 
      continue;
    }
    
    if ( buf[0] == '\0' ) { // got back null value
      is_val_null = true;
      if ( !has_nulls[col_ctr] ) { // got null value when user said no null values
        go_BYE(-1);
      }
    }
    else {
      is_val_null = false;
    }

    //element is not nil, write to not nil buffer
    if ( !is_val_null ) { 
      int8_t bit_idx = row_ctr % 64;
      nn_buf[col_ctr] |= (1 << bit_idx);
    }
    else {
      // bit already 0 during initialization so no need to set it to 0
      nil_ctrs[col_ctr] += 1;
    }

    //nil buffer is full
    if ( ( row_ctr % 64 ) == 63 && has_nulls[col_ctr]) { // ( row_ctr & 0xFF ) == 0xFF 
      fwrite(&(nn_buf[col_ctr]), 1, sizeof(uint64_t), nofps[col_ctr]);
      nn_buf[col_ctr] = 0; //reset
    }

    //write element to file
    switch ( qtypes[col_ctr] ) {
      case I1:
        if ( is_val_null ) { 
          fwrite(&null_val, 1, sizeof(int8_t), ofps[col_ctr]);
        }
        else {
          status = txt_to_I1(buf, &tempI1); 
          fwrite(&tempI1, 1, sizeof(int8_t), ofps[col_ctr]);
        }
//        printf("I1\n");
        break;
      case I2:
        if ( is_val_null ) { 
          fwrite(&null_val, 1, sizeof(int16_t), ofps[col_ctr]);
        }
        else {
          status = txt_to_I2(buf, &tempI2); 
          fwrite(&tempI2, 1, sizeof(int16_t), ofps[col_ctr]);
        }
  //      printf("I2");
        break;
      case I4:
        if ( is_val_null ) { 
          fwrite(&null_val, 1, sizeof(int32_t), ofps[col_ctr]);
        }
        else {
          status = txt_to_I4(buf, &tempI4); 
          fwrite(&tempI4, 1, sizeof(int32_t), ofps[col_ctr]);
        }
    //    printf("I4\n");
        break;
      case I8:
        if ( is_val_null ) { 
          fwrite(&null_val, 1, sizeof(int64_t), ofps[col_ctr]);
        }
        else {
          status = txt_to_I8(buf, &tempI8); 
          fwrite(&tempI8, 1, sizeof(int64_t), ofps[col_ctr]);
        }
        //printf("I8\n");
        break;
      case F4:
        if ( is_val_null ) { 
          fwrite(&null_val, 1, sizeof(float), ofps[col_ctr]);
        }
        else {
          status = txt_to_F4(buf, &tempF4); 
          fwrite(&tempF4, 1, sizeof(float), ofps[col_ctr]);
        }
      //  printf("F4\n");
        break;
      case F8:
        if ( is_val_null ) { 
          fwrite(&null_val, 1, sizeof(double), ofps[col_ctr]);
        }
        else {
          status = txt_to_F8(buf, &tempF8); 
          fwrite(&tempF8, 1, sizeof(double), ofps[col_ctr]);
        }
        //printf("F8\n");
        break;
      default:
        //should not come here
        go_BYE(-1);
        break;
    }
    if ( status < 0 ) { 
      fprintf(stderr, "Error for row %lu, col %d, cell [%s]\n",
          row_ctr, col_ctr, buf);
    }
    cBYE(status);
    col_ctr++;
    if ( col_ctr == nC ) { 
      col_ctr = 0;
      row_ctr++;
    }
    /*this check needs to be done after the file has been written to because it
     * is possible that on the last get_cell, xidx is incremented to file_size
     * or greater, but the value from that last get_cell still needs to be
     * written to file*/
    if ( xidx == file_size ) { break; } // check == or >= 
  }

  //header row
  *ptr_nR = row_ctr;

  //write any remaining nil element info to file
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( nofps[i] != NULL ) {
      fwrite(nn_buf + i, 1, sizeof(uint64_t), nofps[i]);
    }
  }

  //*ptr_nil_ctrs = nil_ctrs; TODO TODO TODO
BYE:
  bak_status = status;

  if ( ofps != NULL ) { 
    for ( uint32_t i = 0; i < nC; i++ ) {
      if ( *outfiles[i] != '\0' ) {
        fclose_if_non_null(ofps[i]);
      }
    }
  }

  //delete nil_files with no nil elements
  if ( nofps != NULL ) { 
    for ( uint32_t i = 0; i < nC; i++ ) {
      if ( nil_ctrs[i] == 0 ) {
        if ( status == 0 ) { 
          printf("%s: no nils in Column %d\n", infile, i);
        }
        if ( nofps[i] != NULL ) { 
          fclose_if_non_null(nofps[i]);
          status = remove(nil_files[i]);
          if ( status == 0 ) { 
            printf("%s: removing file for Column %d\n", infile, i);
          }
        }
      }
      else {
        if ( nofps[i] == NULL ) { go_BYE(-1); }
      }
    }
  }
  rs_munmap(mmap_file, file_size);
  free_if_non_null(ofps);
  free_if_non_null(nofps);
  free_if_non_null(nil_ctrs);

  return bak_status;
}

