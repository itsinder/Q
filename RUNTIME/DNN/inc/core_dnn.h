extern int
dnn_check(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_delete(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_epoch(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_free(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_new(
    DNN_REC_TYPE *ptr_X,
    int bsz,
    int nl,
    int *npl
    );