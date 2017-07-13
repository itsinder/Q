#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include "q_macros.h"

extern int
sum_prod(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double **A, /* M vectors of length M */
    bool std
);
