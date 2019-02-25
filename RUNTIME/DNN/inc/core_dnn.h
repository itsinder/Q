extern int
dnn_check(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_delete(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_fpass(
    DNN_REC_TYPE *ptr_X,
    float **cptrs_in, /* [npl[0]][nI] */
    float **cptrs_out, /* [npl[nl-1]][nI] */
    uint64_t nI // number of instances
    );
extern int
dnn_bprop(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_free(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_new(
    DNN_REC_TYPE *ptr_X,
    int nl,
    int *npl,
    float *dpl
    );
extern int dnn_set_io(
    DNN_REC_TYPE *ptr_dnn,
    int bsz
    );
extern int dnn_unset_io(
    DNN_REC_TYPE *ptr_dnn
    );
