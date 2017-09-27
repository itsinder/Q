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
#include "_rand_file_name.h"
#include "_file_exists.h"
#include "_trim.h"
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
#define LEN_BASE_FILE_NAME 64
#define MAX_LEN_DIR_NAME 255

typedef enum _qtype_type { undef, I1, I2, I4, I8, F4, F8 } qtype_type;
//START_FUNC_DECL
int
load_csv_fast(
    const char * const q_data_dir,
    const char * const infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    char ** const fldtypes, /* [nC] */
    bool is_hdr, /* [nC] */
    bool * const is_load, /* [nC] */
    bool * const has_nulls, /* [nC] */
    uint64_t * const num_nulls, /* [nC] */
    char ***ptr_out_files,
    char ***ptr_nil_files,
    /* Note we set nil_files and out_files only if below == NULL */
    char *str_for_lua,
    size_t sz_str_for_lua 
    )
//STOP_FUNC_DECL
{
  int status = 0, bak_status = 0;
  char *mmap_file = NULL; //X
  size_t file_size = 0; //nX
  FILE **ofps = NULL; /* Output File PointerS */
  FILE **nn_ofps = NULL; /* NN Output File PointerS */
  qtype_type *qtypes = NULL;
  uint64_t *nn_buf = NULL;
  char **out_files = NULL;
  char **nil_files = NULL;
  char *opdir = NULL; 

  //---------------------------------
  if ( ( infile == NULL ) || ( *infile == '\0' ) ) { go_BYE(-1); }
  if ( nC == 0 ) { go_BYE(-1); }
  if ( ptr_nR == NULL ) { go_BYE(-1); }
  if ( ( q_data_dir == NULL ) || ( *q_data_dir == '\0' ) ) {

  if ( out_files == NULL ) { go_BYE(-1); }
#define MAX_LEN_DIR_NAME 255
    char cwd[MAX_LEN_DIR_NAME+1];
    memset(cwd, '\0', MAX_LEN_DIR_NAME+1);
    if ( getcwd(cwd, MAX_LEN_DIR_NAME) == NULL ) { go_BYE(-1); }
    opdir = strdup(cwd);
  }
  else {
    opdir = strdup(q_data_dir);
  }

  //---------------------------------
  // allocate space and initialize other resources

  if ( ( str_for_lua != NULL ) && ( sz_str_for_lua > 0 ) ) {
    memset(str_for_lua, '\0', sz_str_for_lua);
  }

  for ( uint32_t i = 0; i < nC; i++ ) {
    num_nulls[i] = 0;
  }

  nn_buf = malloc(nC * sizeof(uint64_t));
  return_if_malloc_failed(nn_buf);
  out_files = malloc(nC * sizeof(char *));
  return_if_malloc_failed(out_files);
  nil_files = malloc(nC * sizeof(char *));
  return_if_malloc_failed(nil_files);

  for ( uint32_t i = 0; i < nC; i++ ) {
    nn_buf[i] = 0;
    out_files[i] = NULL;
    nil_files[i] = NULL;
  }

  if ( opdir[strlen(opdir)-1] == '/' ) { 
    opdir[strlen(opdir)-1] = '\0';
  }
  int ddir_len = strlen(opdir) + 8 + LEN_BASE_FILE_NAME;
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( !is_load[i] ) { continue; }
    char buf[LEN_BASE_FILE_NAME+1];
    memset(buf, '\0', LEN_BASE_FILE_NAME+1);
    status = rand_file_name(buf, LEN_BASE_FILE_NAME);
    out_files[i] = malloc(ddir_len * sizeof(char));
    sprintf(out_files[i], "%s/", opdir);
    strcat(out_files[i], buf);

    if ( has_nulls[i] ) {
      nil_files[i] = malloc(ddir_len * sizeof(char));
      sprintf(nil_files[i], "%s/_nn", opdir);
      strcat(nil_files[i], buf);
    }

  }

  *ptr_nR = 0;
  // set up qtypes  -- convert from strings to enum
  qtypes = malloc(nC * sizeof(qtype_type));
  return_if_malloc_failed(qtypes);
  bool  some_load = false;
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( !is_load[i] ) {
      qtypes[i] = undef;
      continue;
    }
    some_load = true;
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
  if ( !some_load ) { go_BYE(-1); }
  // malloc output file pointers and nil output file pointers
  ofps = malloc(nC * sizeof(FILE *));
  return_if_malloc_failed(ofps);
  nn_ofps = malloc(nC * sizeof(FILE *));
  return_if_malloc_failed(nn_ofps);
  for ( uint32_t i = 0; i < nC; i++ ) {
    ofps[i] = NULL;
    nn_ofps[i] = NULL;
  }
  // fopen output file pointers and nil output file pointers
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( !is_load[i] ) {
      continue;
    }
    if ( ( out_files[i] == NULL ) || ( out_files[i][0] == '\0' ) ) { 
      go_BYE(-1);
    }
    ofps[i] = fopen(out_files[i], "wb");
    return_if_fopen_failed(ofps[i], out_files[i], "wb");

    if ( has_nulls[i] ) { 
      if ( ( nil_files[i] == NULL ) || ( nil_files[i][0] == '\0' ) ) { 
        go_BYE(-1);
      }
      nn_ofps[i] = fopen(nil_files[i], "wb");
      return_if_fopen_failed(nn_ofps[i], nil_files[i], "wb");
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
  char lbuf[BUFSZ+1];
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

    xidx = get_cell(mmap_file, file_size, xidx, is_last_col, lbuf, BUFSZ);
    if ( xidx == 0 ) { go_BYE(-1); } //means the file is empty or some error
    if ( xidx > file_size ) { break; } // check == or >= 
    status = trim(lbuf, buf, BUFSZ); cBYE(status);

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
    
    if ( lbuf[0] == '\0' ) { // got back null value
      is_val_null = true;
      if ( !has_nulls[col_ctr] ) { 
        // got null value when user said no null values
        go_BYE(-1);
      }
    }
    else {
      is_val_null = false;
    }

    //element is not nil, write to not nil buffer
    if ( !is_val_null ) { 
      int8_t bit_idx = row_ctr % 64;
      nn_buf[col_ctr] |= ((uint64_t)1 << bit_idx);
    }
    else {
      // bit already 0 during initialization so no need to set it to 0
      num_nulls[col_ctr] += 1;
    }

    //nil buffer is full
    if ( ( row_ctr % 64 ) == 63 && has_nulls[col_ctr]) { // ( row_ctr & 0xFF ) == 0xFF 
      fwrite(&(nn_buf[col_ctr]), 1, sizeof(uint64_t), nn_ofps[col_ctr]);
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
    if ( ( nn_ofps[i] != NULL ) && ( row_ctr % 64 != 0 ) ) {
      fwrite(nn_buf + i, 1, sizeof(uint64_t), nn_ofps[i]);
    }
  }
  if ( ( str_for_lua != NULL ) && ( sz_str_for_lua > 0 ) ) {
    strcpy(str_for_lua, "local lVector = require 'Q/RUNTIME/lua/lVector'\nlocal T = {};\n");
    char xbuf[2*ddir_len + 128];
    int xcol_ctr = 1; // Lua indexes from 1 
    for ( uint32_t i = 0; i < nC; i++ ) {
      if ( !is_load[i] ) { continue; }
      if ( num_nulls[i] == 0 ) {  
        sprintf(xbuf, "T[%d] = lVector({ qtype = \"%s\", file_name = \"%s\"});\n", xcol_ctr, fldtypes[i], out_files[i]);
      }
      else {
        sprintf(xbuf, "T[%d] = lVector({ qtype = \"%s\", file_name = \"%s\", nn_file_name = \"%s\" });\n", xcol_ctr, fldtypes[i], out_files[i], nil_files[i]);
      }
      // TODO: Check for buffer overflow 
      strcat(str_for_lua, xbuf);
      xcol_ctr++;
    }
    sprintf(str_for_lua + strlen(str_for_lua),"return T\n");
  }
  else {
    *ptr_out_files = out_files;
    *ptr_nil_files = nil_files;
  }

BYE:
  bak_status = status;
  // Close open files 
  for ( uint32_t i = 0; i < nC; i++ ) {
    fclose_if_non_null(ofps[i]);
    fclose_if_non_null(nn_ofps[i]);
  }

  // delete nil_files with no nil elements
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( !is_load[i] ) { continue; }
    if ( ( has_nulls[i] ) && ( num_nulls[i] == 0 ) ) { 
      if ( nil_files[i][0] == '\0' ) { WHEREAMI; return -1; }
      if ( !file_exists(nil_files[i]) ) { 
        WHEREAMI; return -1; }
      status = remove(nil_files[i]); 
      if ( status < 0 ) { WHEREAMI; return -1; }
      free_if_non_null(nil_files[i]); 
      printf("%s: removing file for Column %d\n", infile, i);
    }
  }
  if ( ( str_for_lua != NULL ) && ( sz_str_for_lua > 0 ) ) {
    // delete nil files and out_files
    if ( nil_files != NULL ) { 
      for ( uint32_t i = 0; i < nC; i++ ) {
        free_if_non_null(nil_files[i]);
      }
      free_if_non_null(nil_files);
    }
    if ( out_files != NULL ) { 
      for ( uint32_t i = 0; i < nC; i++ ) {
        free_if_non_null(out_files[i]);
      }
      free_if_non_null(out_files);
    }
  }

  rs_munmap(mmap_file, file_size);
  free_if_non_null(ofps);
  free_if_non_null(qtypes);
  free_if_non_null(nn_ofps);
  free_if_non_null(opdir);
  free_if_non_null(nn_buf);

  return bak_status;
}

