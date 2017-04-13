#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "q_macros.h"
#include "_mmap.h"
#include "_txt_to_SC.h"
#include "_txt_to_I1.h"
#include "_txt_to_I2.h"
#include "_txt_to_I4.h"
#include "_txt_to_I8.h"
#include "_txt_to_F4.h"
#include "_txt_to_F8.h"

/* Given a single column integer file, it converts it into binary.
   Inputs 
   (1) Input file
   (2) fldtype, can be any qtype
   Output
   (1) Output file
*/

#define MAXLINE 64

typedef enum _qtype_type { I1, I2, I4, I8, F4, F8, SC, TM } qtype_type;
// START FUNC DECL
int
asc2bin(
    char *infile,
    char *fldtype,
    char *outfile,
    int outlen // for SC
     )
// STOP FUNC DECL
{
  int status = 0;
  qtype_type qtype;
  FILE *ifp = NULL;
  FILE *ofp = NULL;
  char *cptr;
  char line[MAXLINE];
  char *opbuf = NULL;

  if ( *infile != '\0' ) {
    if ( strcmp(infile, outfile) == 0 ) { go_BYE(-1); }
  }
  if ( *infile != '\0' ) {
    ifp = fopen(infile, "r");
    return_if_fopen_failed(ifp, infile, "r");
  }
  else {
    ifp = stdin;
  }
  if ( *outfile != '\0' ) { 
    if ( strcmp(infile, outfile) == 0 ) { go_BYE(-1); }
    ofp = fopen(outfile, "wb");
    return_if_fopen_failed(ofp, outfile, "wb");
  }
  else {
    ofp = stdout;
  }

  if ( strcasecmp(fldtype, "I1") == 0 ) {
    qtype = I1;
  }
  if ( strcasecmp(fldtype, "I2") == 0 ) {
    qtype = I2;
  }
  if ( strcasecmp(fldtype, "I4") == 0 ) {
    qtype = I4;
  }
  else if ( strcasecmp(fldtype, "I8") == 0 ) {
    qtype = I8;
  }
  else if ( strcasecmp(fldtype, "F4") == 0 ) {
    qtype = F4;
  }
  else if ( strcasecmp(fldtype, "F8") == 0 ) {
    qtype = F8;
  }
  else if ( strcasecmp(fldtype, "SC") == 0 ) {
    if ( outlen < 2 ) { go_BYE(-1); }
    qtype = SC;
  }
  else if ( strcasecmp(fldtype, "TM") == 0 ) {
    /* not implemented */ go_BYE(-1); 
  }
  else { go_BYE(-1); }

  if ( outlen > 0 ) { 
    opbuf = malloc(outlen * sizeof(char));
    return_if_malloc_failed(opbuf);
  }
  memset(line, '\0', MAXLINE);
  for ( int lno = 0; ; lno++ ) { 
    int8_t tempI1; int16_t tempI2; int32_t tempI4; int64_t tempI8;
    float tempF4; double tempF8;
    char *cptr = fgets(line, MAXLINE, ifp);
    if ( cptr == NULL ) { break; }
    int len = strlen(line);
    if ( len == 0 ) {
      fprintf(stderr, "Error on line %d = [%s] \n", lno, line);
      go_BYE(-1);
    }
    if ( line[len-1] != '\n' ) { go_BYE(-1); }
    line[len-1] = '\0'; len--;
    char *xptr = line;
    if ( line[0] == '"' ) { 
      if ( len <= 2 ) { go_BYE(-1); }
      if ( line[len-1] != '"' ) { go_BYE(-1); }
      xptr = line+1;
    }
    switch ( qtype ) { 
      case I1 : 
        status = txt_to_I1(xptr, 10, &tempI1); cBYE(status);
        fwrite(&tempI1, 1, sizeof(int8_t), ofp);
        break;
      case I2 : 
        status = txt_to_I2(xptr, 10, &tempI2); cBYE(status);
        fwrite(&tempI2, 1, sizeof(int16_t), ofp);
        break;
      case I4 : 
        status = txt_to_I4(xptr, 10, &tempI4); cBYE(status);
        fwrite(&tempI4, 1, sizeof(int32_t), ofp);
        break;
      case I8 : 
        status = txt_to_I8(xptr, 10, &tempI8); cBYE(status);
        fwrite(&tempI8, 1, sizeof(int64_t), ofp);
        break;
      case F4 : 
        status = txt_to_F4(xptr, &tempF4); cBYE(status);
        fwrite(&tempF4, 1, sizeof(float), ofp);
        break;
      case F8 : 
        status = txt_to_F8(xptr, &tempF8); cBYE(status);
        fwrite(&tempF8, 1, sizeof(double), ofp);
        break;
      case SC : 
        memset(opbuf, '\0', len);
        status = txt_to_SC(xptr, opbuf, outlen); cBYE(status);
        fwrite(opbuf, outlen, sizeof(char), ofp);
        break;
      default : 
        go_BYE(-1);
        break;
    }
    memset(line, '\0', MAXLINE);
  }
BYE:
  if ( *infile != '\0' ) { 
    fclose_if_non_null(ifp);
  }
  if ( *outfile != '\0' ) { 
    fclose_if_non_null(ofp);
  }
  return status ;
}
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int len = 0;
  if ( ( argc != 4 ) && ( argc != 5 ) ) { go_BYE(-1); }
  char *infile    = argv[1];
  char *str_qtype = argv[2]; 
  char *opfile    = argv[3];
  if ( argc == 5 ) { 
    char *str_len   = argv[4];
    status = txt_to_I4(str_len, 10, &len); cBYE(status);
    if ( len <= 1 ) { go_BYE(-1); }
  }
  status = asc2bin(infile, str_qtype, opfile, len); cBYE(status);
BYE:
  return status;
}
