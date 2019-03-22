// gcc -mavx2 -mfma -S -c  x.c   # to produce assembler
// gcc -mavx2 -mfma -O4 x.c -lm  # produces executable a.out
#include <immintrin.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <inttypes.h>

#define N 1048576

static uint64_t
RDTSC(
    void
    )
{
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}


int main() {
  float *A = memalign(256, N * sizeof(float));
  float *B = memalign(256, N * sizeof(float));
  float *C = memalign(256, N * sizeof(float));
  float *D = memalign(256, N * sizeof(float));
  for ( int i = 0; i < N; i++ ) { A[i] = i; }
  for ( int i = 0; i < N; i++ ) { B[i] = i*2; }
  for ( int i = 0; i < N; i++ ) { C[i] = i*4; }

  printf("starting\n");
  int register_width_in_bits = 256;
  int bits_per_byte = 8;
  int num_words_in_reg = register_width_in_bits / (bits_per_byte * sizeof(float));
  uint64_t t_end = 0, t_start = RDTSC();
  for ( int i = 0; i < N/num_words_in_reg; i += num_words_in_reg ) { 
    /*
    __m256 a = _mm256_setr_ps(A[i], A[i+1], A[i+2], A[i+3]);
    __m256 b = _mm256_setr_ps(B[i], B[i+1], B[i+2], B[i+3]);
    __m256 c = _mm256_setr_ps(C[i], C[i+1], C[i+2], C[i+3]);
    */
    __m256 a = _mm256_load_ps(A+i);
    __m256 b = _mm256_load_ps(B+i);
    __m256 c = _mm256_load_ps(C+i);

    /* Display the elements of the input vector a */
    /*
    float * aptr = (float*)&a;
    printf("A: %lf %lf %lf %lf\n", aptr[0], aptr[1], aptr[2], aptr[3]);
    float * bptr = (float*)&b;
    printf("B: %lf %lf %lf %lf\n", bptr[0], bptr[1], bptr[2], bptr[3]);
    float * cptr = (float*)&c;
    printf("C: %lf %lf %lf %lf\n", cptr[0], cptr[1], cptr[2], cptr[3]);
    */

    __m256 d = _mm256_fmadd_ps(a, b, c);
    /*
    float * dptr = (float*)&d;
    printf("D: %lf %lf %lf %lf\n", dptr[0], dptr[1], dptr[2], dptr[3]);
    */
    // memcpy(D, dptr, 256);
    //printf("storing..\n");
    _mm256_store_ps(D+i, d);
    //printf("stored\n");
  }
  t_end = RDTSC();
  fprintf(stdout, "cycles  = %" PRIu64 "\n", ( t_end - t_start ));
  for ( int i = 0; i < 8; i++ ) { 
    printf("A = %lf \t", A[i]);
    printf("B = %lf \t", B[i]);
    printf("C = %lf \t", C[i]);
    printf("D = %lf \n", D[i]);
  }


  return 0;
}

/* following gives basic assembler
// gcc -mavx2 -mfma -S x.c   -lm - x 
#include <immintrin.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define N 1048576

int main() {
  float *A;
  float *B;
  float *C;
  float *D;
  int register_width;
  int num_words_in_reg;
  for ( int i = 0; i < N/num_words_in_reg; i += num_words_in_reg ) { 
    __m256 a = _mm256_load_ps(A+i);
    __m256 b = _mm256_load_ps(B+i);
    __m256 c = _mm256_load_ps(C+i);
    __m256 d = _mm256_fmadd_ps(a, b, c);
    _mm256_store_ps(D+i, d);
  }
  return 0;
}
*/
