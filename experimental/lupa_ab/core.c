#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#include "core.h"


void *
init_ab_copy(
    const char *conf_file,
    int size
    )
{
  AB_ARGS_TYPE *ptr_ab_args = NULL;
  ptr_ab_args = malloc(sizeof(AB_ARGS_TYPE));

  // Initialize structure
  ptr_ab_args->size = size;
  ptr_ab_args->values = malloc(sizeof(float)*size);
  for ( int i = 0; i < size; i++ ) {
    ptr_ab_args->values[i] = i + 1;
  }
  memcpy(ptr_ab_args->conf_file, conf_file, 100);
  return ptr_ab_args;
}


int
init_ab(
    void *in_ptr_args,
    const char *conf_file,
    int size
    ) 
{
  int status = 0;
  AB_ARGS_TYPE *ptr_ab_args;
  ptr_ab_args = (AB_ARGS_TYPE *)in_ptr_args;

  // Initialize structure
  ptr_ab_args->size = size;
  ptr_ab_args->values = malloc(sizeof(float)*size);
  for ( int i = 0; i < size; i++ ) {
    ptr_ab_args->values[i] = i + 1;
  }
  memcpy(ptr_ab_args->conf_file, conf_file, 100);
  return status;
}

int
sum_ab(
   void *in_ptr_args,
   int factor
   )
{
  AB_ARGS_TYPE *ptr_ab_args;
  ptr_ab_args = (AB_ARGS_TYPE *)in_ptr_args;
  printf("SIZE = %d\n", ptr_ab_args->size);
  int sum = 0;
  for ( int i = 0; i < ptr_ab_args->size; i++ ) {
    sum = sum + ( factor * ptr_ab_args->values[i] );
  }
  return sum;
}

void
print_ab(
     void *in_ptr_args
     )
{
  AB_ARGS_TYPE *ptr_ab_args;
  ptr_ab_args = (AB_ARGS_TYPE *)in_ptr_args;
  printf("=============================================\n");
  printf("Config file name = %s\n", ptr_ab_args->conf_file);
  printf("=============================================\n");
  for ( int i = 0; i < ptr_ab_args->size; i++ ) {
    printf("%f ", ptr_ab_args->values[i]);
  }
  printf("\n");
  printf("=============================================\n");
}

int
free_ab(
    void *in_ptr_args
    )
{
  int status = 0;
  AB_ARGS_TYPE *ptr_ab_args;
  ptr_ab_args = (AB_ARGS_TYPE *)in_ptr_args;
  free(ptr_ab_args->values);
  free(ptr_ab_args);
  printf("Freed up AB structure memory\n");
  return status;
}

int
main()
{
  AB_ARGS_TYPE *X = NULL;
  X = malloc(sizeof(AB_ARGS_TYPE));
  int status = init_ab(X, "my_config", 20);
  printf("init() status = %d\n", status);
  int result = sum_ab(X, 2);
  printf("Sum = %d\n", result);
  print_ab(X);
  free_ab(X);
  printf("====================================");
  AB_ARGS_TYPE *X_NEW = init_ab_copy("my_config", 20);
  int result_new = sum_ab(X_NEW, 2);
  printf("Sum = %d\n", result_new);
  print_ab(X_NEW);
  free_ab(X_NEW);

  return 0;
}
