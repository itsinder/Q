extern int
load_csv_fast(
    const char * const q_data_dir,
    const char * const infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    char **fldtypes, /* [nC] */
    bool is_hdr, /* [nC] */
    bool *is_load, /* [nC] */
    bool *has_nulls, /* [nC] */
    uint64_t *num_nulls, /* [nC] */
    char ***ptr_out_files,
    char ***ptr_nil_files,
    /* Note we use nil_files and out_files only if below == NULL */
    char *output_str_for_lua,
    size_t sz_output_for_lua 
    );
