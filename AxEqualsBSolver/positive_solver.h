extern int positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    );

// destructively updates A and b
extern int positive_solver_fast(
    double ** A, 
    double * x, 
    double * b, 
    int n
    );
