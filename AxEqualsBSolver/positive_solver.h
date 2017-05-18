/* All functions expect column oriented matrices.

   A *compact* symmetric matrix stores only the lower
   (equivalently upper) triangular elements of a matrix A,
   e.g. if the matrix is
   [ 1, 2, 3 ]
   [ 2, 4, 5 ]
   [ 3, 5, 6 ]
   A should be
   A[0] = [ 1, 2, 3 ]
   A[1] = [    4, 5 ]
   A[2] = [       6 ]

   A *full* matrix simply stores each column of the matrix.

   Since these operations aren't always guaranteed to find a solution
   but the operations are on floating numbers, it is up to the caller
   to confirm that the returned solution is correct up to their desired
   level of accuracy.
*/

/* Expects a compact positive semidefinite matrix.
   Preserves its input.
 */
extern int posdef_positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    );

/* Expects a compact positive semidefinite matrix.
   Destructively updates its input.
 */
extern int posdef_positive_solver_fast(
    double ** A,
    double * x,
    double * b,
    int n
    );

/* Expects a full positive semidefinite matrix.
   Preserves its input.
*/
extern int full_posdef_positive_solver_fast(
    double ** A,
    double * x,
    double * b,
    int n
    );

/* Expects a full positive semidefinite matrix.
   Destructively updates its input.
*/
extern int full_posdef_positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    );

/* Expects a full matrix of any kind.
   Preserves its input.
 */
extern int positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    );
