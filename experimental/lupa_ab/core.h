typedef struct _ab_args {
  char conf_file[100];
  int size;
  float * values;
} AB_ARGS;

extern
int
init_ab(
    void *in_ptr_args,
    const char *conf_file,
    int size
    );

extern
int
sum_ab(
   void *in_ptr_args,
   int factor
   );

extern
void
print_ab(
     void *in_ptr_args
     );

extern
int
free_ab(
    void *in_ptr_args
    );

