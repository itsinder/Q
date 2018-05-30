//START_INCLUDES
#include <stdio.h>
#include <stdint.h>
//#include <intrin.h>
//STOP_INCLUDES
#include<_rdtsc.h> 
//  Windows
//uint64_t rdtsc(){
//    return __rdtsc();
//}
//  Linux/GCC
//START_FUNC_DECL
uint64_t
rdtsc(
    )
//STOP_FUNC_DECL  
{
    unsigned int lo,hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}

/* 
int main(int argc, char* argv[]) {
  uint64_t tick = rdtsc();  // tick before
  int i ;
  for (i = 1; i < argc; ++ i) {
    system(argv[i]); // start the command
  }
  // printf("%ld",rdtsc() - tick); // difference
  return 0;
}
*/
