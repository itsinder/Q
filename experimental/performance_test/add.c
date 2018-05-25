#include<stdio.h>
#include<stdlib.h>
#include<inttypes.h>
#include<stdint.h>

uint64_t add( uint64_t limit ) {
  uint64_t sum = 0;
  for( uint64_t i = 1; i <= limit; i++ ) {
    sum = sum + i;
  }
  return sum;
}
/*
int main(int argc, char **argv) {
  uint64_t limit = atoi(argv[1]);
  uint64_t result = 0;
  result = add(limit);
  printf("%" PRIu64 "\n", result);
  return 0;
}
*/
