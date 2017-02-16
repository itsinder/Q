extern void  free_matrix(
      double **A,
      int n
      );
extern void multiply_matrix_vector(
    double **A, 
    double *x,
    int n,
    double *b
    );
extern int alloc_matrix(
    double ***ptr_X, 
    int n
    );
extern void 
multiply(
    double **A,
    double **B,
    double **C,
    int n
    );
extern void 
transpose(
    double **A,
    double **B,
    int n
    );
extern void
print_input(
    double **A, 
    double **Aprime,
    double *x, 
    double *b, 
    int n
    );
extern uint64_t 
RDTSC(
    void
    );
extern int
convert_matrix_for_solver(
    double **A,
    int n,
    double ***ptr_Aprime
    );
