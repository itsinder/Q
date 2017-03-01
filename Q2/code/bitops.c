/* START HDR FILES  */
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
//#include "../../AxEqualsBSolver/macros.h"
#define SET_BIT(x,i)  (x)[(i) / 8] |= (1 << ((i) % 8))
#define CLEAR_BIT(x,i) (x)[(i) / 8] &= ~(1 << ((i) % 8))
#define GET_BIT(x,i) ((x)[(i) / 8] & (1 << ((i) % 8))) > 0
//#define cBYE(i) (i) < 1 && return -1

inline int get_bit(const int* x, int i){
    return x[i/8] & (1 << (i%8));
}

inline int set_bit(int* x, int i){
    return x[i/8] |= 1 << (i % 8);
}

inline int clear_bit(int *x, int i){
return x[i / 8] &= ~(1 << (i % 8));
}

int copy_bits(unsigned char* dest, unsigned char* src, int dest_start_index, int src_start_index, int length){

    for( int i=0; i<length; i++){
        int src_bit = GET_BIT(src, src_start_index + i);
        if (src_bit) {
            SET_BIT(dest, dest_start_index + i);
        } else {
            CLEAR_BIT(dest, dest_start_index + i);
        }
    }
    return 0;
}


int write_bits_to_file(FILE* fp, unsigned char* src, int length, int file_size ) {
    // bring file to the position of the last valid byte and then read off each bit
    // since only the last byte is ever in question we can start from there
    unsigned int val = 0;
    int offset = 0;
    int status;
    status = fseek(fp, file_size/8, SEEK_SET);
    //cBYE(status);
    if (file_size % 8 != 0) {
        val = fgetc(fp);
        status = fseek(fp, -1, SEEK_CUR);
        //cBYE(status);
        offset = 8 - (file_size % 8);
        for( int i=0; i < offset; i++ ) {
            int src_bit = GET_BIT(src, i);
            if (src_bit) {
                SET_BIT(&val, (file_size % 8) + i);
            } else {
                CLEAR_BIT(&val, (file_size % 8) + i);
            }
        }
        //status check
        status = fputc(val, fp);
        //cBYE(status);
        val = 0;
    }

    for (int i = 0; i + offset < length; i++) {
        int src_index = i + offset;
        if ( i % 8 == 0 && i != 0){
            //status check
            status = fputc(val, fp);
            //cBYE(status);
            val = 0;
        }
        int src_bit = GET_BIT(src, src_index);
        if (src_bit) {
            SET_BIT(&val, i % 8);
        } else {
            CLEAR_BIT(&val, i % 8);
        }
    }

    if ( val != 0 ){
        //status check
        status = fputc(val, fp);
        //cBYE(status);
        val = 0;
    }
    return 0;
}

int print_bits(char * file_name, int length) {
    int file_length = length;
    if (file_name == NULL) {
        return -1;
    }
    FILE* fp = fopen(file_name, "rb");
    if (fp == NULL) {
        return -1;
    }
    if (file_length == -1){
    int fd = open(file_name, O_RDONLY);
    struct stat filestat;
    int status = fstat(fd, &filestat);
    //cBYE(status);
    file_length = filestat.st_size;
    }
    unsigned char byte;
    for (int i=0; i < file_length; i++) {
        byte = fgetc(fp);
        for (int j =0; j<8; j++){
            printf("%d\n", GET_BIT(&byte,j));
        }
    }
    return 0;
}

int get_bits_from_array(unsigned char* input_arr, int* arr, int length){
    unsigned char byte;
    for (int i=0; i< length; i++){
        if (length % 8 == 0 ){
             byte = input_arr[length / 8];
        }
        arr[i] = GET_BIT(&byte,i % 8);
    }
    return 0;
}


int get_bits_from_file(FILE* fp, int* arr, int length){
    unsigned char byte;
    for (int i=0; i< length; i++){
        if (length % 8 == 0 ){
             byte = fgetc(fp);
        }
        arr[i] = GET_BIT(&byte,i % 8);
    }
    return 0;
}

int create_bit_file(char* path, int* arr, int length) {
    int arr_length = length/8, status = 0;
    if (length %8 != 0 ) {
        arr_length +=1;
    }
    FILE* fp = fopen(path, "wb+");
    if (fp == NULL) {
        return -1;
    }
    unsigned char vec[arr_length];
    for (int i=0; i< length; i++) {
        if (arr[i] ==0 ) {
            CLEAR_BIT(vec, i);
        }else {
            SET_BIT(vec,i);
        }
    }
    status = write_bits_to_file(fp, vec, length, 0);
    if (status == -1 ) {
        fclose(fp);
        return -1;
    }
    fclose(fp);
    return 0;
}

#ifdef TEST
int main() {
    const char* f_name = "test_bits.txt";
    unsigned char vec[10] = {0};
    for (int i =0 ; i< 8 * sizeof(vec) ; i++){
        if (i % 3 == 0) {
            SET_BIT(vec, i);
        } else {
         CLEAR_BIT(vec, i);
        }
    }
    FILE* fp = fopen(f_name, "wb+");
    write_bits_to_file(fp, vec, 8*sizeof(vec),0);
    //fflush(fp);
    write_bits_to_file(fp, vec, 1, 80 );
    write_bits_to_file(fp, vec, 1, 81 );
    write_bits_to_file(fp, vec, 1, 82 );

    fclose(fp);
    fp = fopen(f_name, "rb");
    struct stat filestat;
    int fd = open(f_name, O_RDONLY);
    int status = fstat(fd, &filestat);
    //cBYE(status);
    int len = filestat.st_size;
    unsigned char byte;
    for (int i=0; i<len; i++) {
        byte = fgetc(fp);
        for (int j =0; j<8; j++){
            printf("%d\n", GET_BIT(&byte,j));
        }
    }

}
#endif

