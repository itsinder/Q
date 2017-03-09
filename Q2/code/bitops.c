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
#define GET_BIT(x,i) (((x)[(i) / 8] & (1 << ((i) % 8))) > 0)
//#define cBYE(i) (i) < 1 && return -1

inline int get_bit(const int* x, int i)
{
    return x[i / 8] & (1 << (i % 8));
}

inline int set_bit(int* x, int i)
{
    return x[i / 8] |= 1 << (i % 8);
}

inline int clear_bit(int *x, int i)
{
    return x[i / 8] &= ~(1 << (i % 8));
}

int copy_bits(unsigned char* dest, unsigned char* src, int dest_start_index, int src_start_index, int length)
{

    for ( int i = 0; i < length; i++)
    {
        int src_bit = GET_BIT(src, src_start_index + i);
        if (src_bit)
        {
            SET_BIT(dest, dest_start_index + i);
        }
        else
        {
            CLEAR_BIT(dest, dest_start_index + i);
        }
    }
    return 0;
}


int write_bits_to_file(FILE* fp, unsigned char* src, int length, int file_size )
{
    // bring file to the position of the last valid byte and then read off each bit
    // since only the last byte is ever in question we can start from there
    unsigned char val = 0;
    int offset = 0;
    int copied_count = 0;
    int status;
#ifdef TEST
    printf("file size=%d, length=%d\n", file_size, length);
#endif
    status = fseek(fp, file_size / 8, SEEK_SET);
#ifdef TEST
    printf("Starting position =%ld\n", ftell(fp));
#endif
    if (status != 0 )
    {
        printf("Error in seeking file");
    }
    //cBYE(status);
    if (file_size % 8 != 0)
    {
#ifdef TEST
        printf("Position before getting an element=%ld\n", ftell(fp));
#endif
        val = fgetc(fp);
        status = fseek(fp, -1, SEEK_CUR);
#ifdef TEST
        printf(" Positionafter getting bit and stepping back =%ld\n", ftell(fp));
#endif
        //cBYE(status);
        //offset = 8 - (file_size % 8);
        offset = file_size % 8 ;
        for ( int i = 0; i + offset < 8 && i < length; i++ )
        {
            unsigned char src_bit = GET_BIT(src, i);
            if (src_bit)
            {
                SET_BIT(&val, offset + i);
            }
            else
            {
                CLEAR_BIT(&val, offset + i);
            }
        }
        copied_count = 8 - offset;
        //status check
#ifdef TEST
        printf("Position before putting the char back=%ld\n", ftell(fp));
#endif
        status = fputc(val, fp);
#ifdef TEST
        printf("Position after putting the char back=%ld\n", ftell(fp));
        //status = fseek(fp, file_size/8 + 1, SEEK_SET);
        //printf("Position after manual seek=%ld\n", ftell(fp));
#endif
        //cBYE(status);
        val = 0;
    }

    for (int i = 0; i + copied_count < length; i++)
    {
        int src_index = i + copied_count;
        if ( i % 8 == 0 && i != 0)
        {
            //status check
            status = fputc(val, fp);
            //cBYE(status);
            val = 0;
        }
        int src_bit = GET_BIT(src, src_index);
        if (src_bit != 0 )
        {
            SET_BIT(&val, i % 8);
        }
        else
        {
            CLEAR_BIT(&val, i % 8);
        }
    }

    if ( val != 0 )
    {
        //status check
        status = fputc(val, fp);
        //cBYE(status);
        val = 0;
    }
    return 0;
}

int print_bits(char * file_name, int length)
{
    int file_length = length;
    if (file_name == NULL)
    {
        return -1;
    }
    FILE* fp = fopen(file_name, "rb");
    if (fp == NULL)
    {
        return -1;
    }
    if (file_length == -1)
    {
        int fd = open(file_name, O_RDONLY);
        struct stat filestat;
        int status = fstat(fd, &filestat);
        //cBYE(status);
        file_length = filestat.st_size;
    }
    unsigned char byte;
    for (int i = 0; i < file_length; i++)
    {
        byte = fgetc(fp);
        for (int j = 0; j < 8; j++)
        {
            printf("%d\n", GET_BIT(&byte, j));
        }
    }
    return 0;
}

int get_bits_from_array(unsigned char* input_arr, int* arr, int length)
{
    unsigned char byte;
    for (int i = 0; i < length; i++)
    {
        arr[i] = GET_BIT(input_arr, i);
    }
    return 0;
}


int get_bits_from_file(FILE* fp, int* arr, int length)
{
    unsigned char byte;
    for (int i = 0; i < length; i++)
    {
        if (i % 8 == 0 )
        {
            byte = fgetc(fp);
        }
        arr[i] = GET_BIT(&byte, i % 8);
    }
    return 0;
}

int create_bit_file(char* path, int* arr, int length)
{
    int arr_length = length / 8, status = 0;
    if (length % 8 != 0 )
    {
        arr_length += 1;
    }
    FILE* fp = fopen(path, "wb+");
    if (fp == NULL)
    {
        return -1;
    }
    unsigned char vec[arr_length];
    for (int i = 0; i < length; i++)
    {
        if (arr[i] == 0 )
        {
            CLEAR_BIT(vec, i);
        }
        else
        {
            SET_BIT(vec, i);
        }
    }
    status = write_bits_to_file(fp, vec, length, 0);
    if (status == -1 )
    {
        fclose(fp);
        return -1;
    }
    fclose(fp);
    return 0;
}

#ifdef TEST


int create_test_file(char * path)
{
    // checked manually to be working
    FILE* fp = fopen(path, "wb+");
    if (fp == NULL)
    {
        printf ("Error in opening file for test read bits from file");
    }
    unsigned char a = 255; // all 1
    fputc(a, fp);
    a = 85;
    fputc(a, fp);
    fclose(fp);
    return 0;

}
void test_read_bits_from_file()
{
    char * path = "./test_read.txt";
    if (create_test_file(path))
    {
        printf("Error creating test file");
        return;
    }
    int arr[16];

    FILE* fp = fopen(path, "rb");
    if (fp == NULL)
    {
        printf("Opening file for reading failed");
        return;
    }

    get_bits_from_file(fp, arr, 16);
    for (int i = 0; i < 16; i++)
    {
        if (i < 8)
        {
            printf("READ for index %d should return %d, returned %d\n", i, arr[i], 1);
        }
        else
        {
            printf("READ for index %d should return %d, returned %d\n", i, arr[i], (i - 1) % 2);
        }
    }
}

void test_write_bits_to_file()
{
    const char* f_name = "test_write.txt";
    unsigned char vec = 0;
    for (int i = 0 ; i < 8 * sizeof(vec) ; i++)
    {
        if (i % 3 == 0)
        {
            SET_BIT(&vec, i);
        }
        else
        {
            CLEAR_BIT(&vec, i);
        }
    }
    FILE* fp = fopen(f_name, "wb+");
    write_bits_to_file(fp, &vec, 1 , 0);
    write_bits_to_file(fp, &vec, 1 , 1);
    write_bits_to_file(fp, &vec, 4 , 2);
    write_bits_to_file(fp, &vec, 4 , 3);


    //write_bits_to_file(fp, &vec, 4 , 8);
    //fflush(fp);
    //write_bits_to_file(fp, &vec, 3, 4 );
    fseek(fp, 0, SEEK_SET);
    int ret_val = fgetc(fp);
    printf("WRITE to file should return %d, returned %d\n", 79, ret_val);
    fclose(fp);

}
//int get_bits_from_array(unsigned char* input_arr, int* arr, int length)
void test_get_bits_from_array()
{
    int arr[32] = {0};
    unsigned char a = 31;
    get_bits_from_array(&a, arr, 8);
    for (int i = 0; i < 8; i++)
    {
        if (i <= 4)
        {
            printf("ARRAY for index %d should return %d , returned %d\n", i, 1 , arr[i] );
        }
        else
        {
            printf("ARRAY for index %d should return %d , returned %d\n", i, 0 , arr[i]);
        }
    }
    a = 8;
    get_bits_from_array(&a, arr, 8);
    for (int i = 0; i < 8; i++)
    {
        if (i == 3)
        {
            printf("ARRAY for index %d should return %d , returned %d\n", i, 1 , arr[i]);
        }
        else
        {
            printf("ARRAY for index %d should return %d , returned %d\n", i, 0 , arr[i]);
        }
    }


}

void test_get_bit()
{
    unsigned char a = 7;
    printf("GETBIT should return %d , returned %d\n", 0 , GET_BIT(&a, 3) );
    printf("GETBIT should return %d , returned %d\n", 1 , GET_BIT(&a, 2) );
    printf("GETBIT should return %d , returned %d\n", 1 , GET_BIT(&a, 1) );
    printf("GETBIT should return %d , returned %d\n", 1 , GET_BIT(&a, 0) );
    a = 8;
    printf("GETBIT should return %d , returned %d\n", 0 , GET_BIT(&a, 3) );
}

void test_set_bit()
{
    unsigned char a = 0;
    printf("SETBIT should return %d , returned %d\n", 1 , SET_BIT(&a, 0) );
    printf("SETBIT should return %d , returned %d\n", 3 , SET_BIT(&a, 1) );
    printf("SETBIT should return %d , returned %d\n", 7 , SET_BIT(&a, 2) );
    printf("SETBIT should return %d , returned %d\n", 15 , SET_BIT(&a, 3) );
    printf("SETBIT should return %d , returned %d\n", 31 , SET_BIT(&a, 4) );
    printf("SETBIT should return %d , returned %d\n", 63 , SET_BIT(&a, 5) );
    printf("SETBIT should return %d , returned %d\n", 127 , SET_BIT(&a, 6) );
    printf("SETBIT should return %d , returned %d\n", 255 , SET_BIT(&a, 7) );

}

void test_clear_bit()
{
    unsigned char a = 255;
    printf("CLEARBIT should return %d , returned %d\n", 254 , CLEAR_BIT(&a, 0) );
    printf("CLEARBIT should return %d , returned %d\n", 252 , CLEAR_BIT(&a, 1) );
    printf("CLEARBIT should return %d , returned %d\n", 248 , CLEAR_BIT(&a, 2) );
    printf("CLEARBIT should return %d , returned %d\n", 240 , CLEAR_BIT(&a, 3) );
    printf("CLEARBIT should return %d , returned %d\n", 224 , CLEAR_BIT(&a, 4) );
    printf("CLEARBIT should return %d , returned %d\n", 192 , CLEAR_BIT(&a, 5) );
    printf("CLEARBIT should return %d , returned %d\n", 128 , CLEAR_BIT(&a, 6) );
    printf("CLEARBIT should return %d , returned %d\n", 0 , CLEAR_BIT(&a, 7) );

}

int main()
{
    const char* f_name = "test_bits.txt";
    unsigned char vec[10] = {0};
    for (int i = 0 ; i < 8 * sizeof(vec) ; i++)
    {
        if (i % 3 == 0)
        {
            SET_BIT(vec, i);
        }
        else
        {
            CLEAR_BIT(vec, i);
        }
    }
    FILE* fp = fopen(f_name, "wb+");
    write_bits_to_file(fp, vec, 8 * sizeof(vec), 0);
    //fflush(fp);
    write_bits_to_file(fp, vec, 10, 0 );
    write_bits_to_file(fp, vec, 5, 0 );
    write_bits_to_file(fp, vec, 1, 10 );
    write_bits_to_file(fp, vec, 1, 11 );
    fclose(fp);
    fp = fopen(f_name, "rb");
    struct stat filestat;
    int fd = open(f_name, O_RDONLY);
    int status = fstat(fd, &filestat);
    //cBYE(status);
    int len = filestat.st_size;
    unsigned char byte;
    for (int i = 0; i < len; i++)
    {
        byte = fgetc(fp);
        for (int j = 0; j < 8; j++)
        {
            printf("%d\n", GET_BIT(&byte, j));
        }
    }

    test_get_bit();
    test_set_bit();
    test_clear_bit();
    test_get_bits_from_array();
    test_read_bits_from_file();
    test_write_bits_to_file();
}

#endif
