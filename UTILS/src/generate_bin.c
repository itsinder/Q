#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "q_macros.h"

typedef enum _qtype_type { undef_qtype, B1, I1, I2, I4, I8, F4, F8, SC, TM } qtype_type;

int 
generate_bin(
    int num_values, 
    char* fldtype, 
    char* outfile, 
    char* gen_type
    ) 
{
    int status = 0;
    FILE *ofp = NULL;
    
    if ( *outfile == '\0' ) { go_BYE(-1); }
    if ( *fldtype == '\0' ) { go_BYE(-1); }
    if ( num_values < 1 ) { go_BYE(-1); }
    
    qtype_type qtype = undef_qtype;
    ofp = fopen(outfile, "wb");
    return_if_fopen_failed(ofp, outfile, "wb");
    
    if ( strcmp(fldtype, "B1") == 0 ) {
        qtype = B1;
    }
    else if ( strcmp(fldtype, "I1") == 0 ) {
        qtype = I1;    
    }
    else if ( strcmp(fldtype, "I2") == 0 ) {
        qtype = I2;
    }
    else if ( strcmp(fldtype, "I4") == 0 ) {
        qtype = I4;
    }
    else if ( strcmp(fldtype, "I8") == 0 ) {
        qtype = I8;
    }
    else if ( strcmp(fldtype, "F4") == 0 ) {
        qtype = F4;
    }
    else if ( strcmp(fldtype, "F8") == 0 ) {
        qtype = F8;
    }
    else {
        go_BYE(-1);
    }
    if ( qtype == undef_qtype ) { go_BYE(-1); }
    int8_t tempI1;
    int16_t tempI2;
    int32_t tempI4;
    int64_t tempI8;
    float tempF4;
    double tempF8;
    for ( uint64_t i = 1; i <= num_values; i++ ) {
        uint64_t val = i;
        // Calculate value of 'val' depending on 'gen_type'
        switch ( qtype ) {
            case B1 :
                // Not Implemented
                break;
            case I1 :
                tempI1 = (int8_t) val;
                fwrite(&tempI1, 1, sizeof(int8_t), ofp);
                break;
            case I2 :
                tempI2 = (int16_t) val;
                fwrite(&tempI2, 1, sizeof(int16_t), ofp);
                break;
            case I4 :
                tempI4 = (int32_t) val;
                fwrite(&tempI4, 1, sizeof(int32_t), ofp);
                break;
            case I8 :
                tempI8 = (int64_t) val;
                fwrite(&tempI8, 1, sizeof(int64_t), ofp);
                break;
            case F4 :
                tempF4 = (float) val;
                fwrite(&tempF4, 1, sizeof(float), ofp);
                break;
            case F8 :
                tempF8 = (double) val;
                fwrite(&tempF8, 1, sizeof(double), ofp);
                break;
            default :
                go_BYE(-1);
                break;
        }
    }
BYE:
  if ( *outfile != '\0' ) {
    fclose_if_non_null(ofp);
  }
  return status ;
}

int main(
    int argc,
    char **argv
    )
{
    int status = 0;
    int num_values = atoi(argv[1]);
    char *fldtype = argv[2];
    char *outfile = argv[3];
    char *gen_type = argv[4];
   
    status = generate_bin(num_values, fldtype, outfile, gen_type); cBYE(status);
    printf("Generate bin status is %d\n", status);
BYE:
    return status;
}
