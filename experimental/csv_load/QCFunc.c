#include<stdint.h>
#include<stdio.h>
#include<string.h>


///////////////// File Operations ///////////

//TODO : Change createFile to some sort of openfile function.. so that same can be used to open in read/write/ binary mode
FILE * createFile(const char *fname){
  FILE *file = fopen(fname, "wb");
	return file;
}

void close(FILE *fp){
	int status = fclose(fp);
}

void write(FILE *fp, const void* val, int size){
  if(fp == NULL){
        printf("ERROR : File pointer is NUll ");
  }else{
    fwrite((const void*)val,size,1,fp);
  }	
}



int txt_to_d(const char *X, double *ptr_out){
  int status = 0;
  char *endptr;
  *ptr_out = strtod(X, &endptr,10);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { printf("Error Occured"); }
  return status ;
}
int txt_to_I1(const char *X, int8_t *ptr_out){
  int status = 0;
  char *endptr;
  *ptr_out = strtol(X, &endptr,10);
  
  if(endptr == NULL){ 
    printf("Pointer is null");
  }else{
    if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { printf("Error Occured"); }
  }
  return status ;
}

int txt_to_I2(const char *X, int16_t *ptr_out){
  int status = 0;
  char *endptr;
  *ptr_out = strtol(X, &endptr,10);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { printf("Error Occured"); }
  return status ;
}
int txt_to_I4(const char *X, int32_t *ptr_out){
  int status = 0;
  char *endptr;
  *ptr_out = strtol(X, &endptr,10);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { printf("Error Occured"); }
  return status ;
}
int txt_to_I8(const char *X, int64_t *ptr_out){
  int status = 0;
  char *endptr;
  *ptr_out = strtoll(X, &endptr,10);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { printf("Error Occured"); }
  return status ;
}

