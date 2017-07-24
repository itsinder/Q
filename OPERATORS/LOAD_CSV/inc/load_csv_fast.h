extern int
load_csv_fast(
    char *infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    const char **outfiles,
    const char **fldtypes,
    bool is_hdr,
    bool *is_load,
    bool *has_nulls,
    const char **nil_files//, TODO TODO TODO
    //uint64_t *ptr_nil_ctrs
    );
