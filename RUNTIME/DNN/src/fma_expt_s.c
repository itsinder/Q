// gcc -mavx2 -mfma -S x.c   -lm - x 
#include <immintrin.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define N 1048576

int main() {
  float *A = memalign(256, N * sizeof(float));
  float *B = memalign(256, N * sizeof(float));
  float *C = memalign(256, N * sizeof(float));
  float *D = memalign(256, N * sizeof(float));
  for ( int i = 0; i < N; i++ ) { A[i] = i; }
  for ( int i = 0; i < N; i++ ) { B[i] = i*2; }
  for ( int i = 0; i < N; i++ ) { C[i] = i*4; }

  printf("starting\n");
  for ( int i = 0; i < 1; i++ ) { 
    /*
    __m256 a = _mm256_setr_ps(A[i], A[i+1], A[i+2], A[i+3]);
    __m256 b = _mm256_setr_ps(B[i], B[i+1], B[i+2], B[i+3]);
    __m256 c = _mm256_setr_ps(C[i], C[i+1], C[i+2], C[i+3]);
    */
    __m256 a = _mm256_load_ps(A+i);
    __m256 b = _mm256_load_ps(B+i);
    __m256 c = _mm256_load_ps(C+i);

    /* Display the elements of the input vector a */
    float * aptr = (float*)&a;
    printf("A: %lf %lf %lf %lf\n", aptr[0], aptr[1], aptr[2], aptr[3]);
    float * bptr = (float*)&b;
    printf("B: %lf %lf %lf %lf\n", bptr[0], bptr[1], bptr[2], bptr[3]);
    float * cptr = (float*)&c;
    printf("C: %lf %lf %lf %lf\n", cptr[0], cptr[1], cptr[2], cptr[3]);

    __m256 d = _mm256_fmadd_ps(a, b, c);
    float * dptr = (float*)&d;
    printf("D: %lf %lf %lf %lf\n", dptr[0], dptr[1], dptr[2], dptr[3]);
    // memcpy(D, dptr, 256);
    printf("storing..\n");
    _mm256_store_ps(D, d);
    printf("stored\n");
  }

  for ( int i = 0; i < 8; i++ ) { 
    printf("A = %lf \t", A[i]);
    printf("B = %lf \t", B[i]);
    printf("C = %lf \t", C[i]);
    printf("D = %lf \n", D[i]);
  }


  return 0;
}


