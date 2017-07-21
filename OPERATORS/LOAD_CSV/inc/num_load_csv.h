#include <stdio.h>
#include <stdbool.h>
#include "q_macros.h"
#include "_txt_to_I1.h"
#include "_txt_to_I2.h"
#include "_txt_to_I4.h"
#include "_txt_to_I8.h"
#include "_txt_to_F4.h"
#include "_txt_to_F8.h"
#include "_get_cell.h"
#include "_mmap.h"
extern int
num_load_csv(
    char *infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    const char **outfiles,
    const char **fldtypes,
    bool is_hdr,
    bool *is_load,
    const char **nil_files
    );
