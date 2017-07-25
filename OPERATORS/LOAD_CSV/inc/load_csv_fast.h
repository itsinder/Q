extern int
load_csv_fast(
    const char * const infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    char **outfiles,
    char **fldtypes,
    bool is_hdr,
    bool *is_load,
    bool *has_nulls,
    char **nil_files//, TODO TODO TODO
    //uint64_t *ptr_nil_ctrs
    );
