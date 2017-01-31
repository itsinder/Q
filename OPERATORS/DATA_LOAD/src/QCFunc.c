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

void writeNull(FILE *fp, uint8_t val, int size)
{
 
 if(fp == NULL){
        printf("ERROR : File pointer is NUll ");
  }else{
    fwrite((const void*)&val,size,1,fp);
  }	
}

uint8_t setBit(int colno, uint8_t byteval, int row_cnt)
{
   int maxbitval=8,temp=1,i;
   
   row_cnt = row_cnt % maxbitval;
   if (row_cnt == 0) { row_cnt =8;}
			for(i = maxbitval; i > row_cnt; i--) { temp=temp*2;}
    
			byteval = byteval |  temp;
     
      return byteval;
}
