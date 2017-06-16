struct frequent_persistent_data {
  int *packet_space;
  int *cntr_id;
  int *cntr_freq;
  int cntr_siz;
  long long active_cntr_siz;
  int *bf_id;
  int *bf_freq;
  long long siz;
  long long min_freq;
  long long err;
  long long max_chunk_size;
};

int
allocate_persistent_data(
    long long siz,
    long long min_freq,
    long long err,
    long long max_chunk_size,
    struct frequent_persistent_data *data);

extern int
process_chunk(
    int *chunk,
    int chunk_siz,
    struct frequent_persistent_data *data);

extern int
process_output(
    struct frequent_persistent_data *data,
    int **y,
    int **f,
    int *out_len);

extern void free_persistent_data(struct frequent_persistent_data *data);

extern int
approx_frequent (
    int * x,
    long long siz,
    long long min_freq,
    long long err,
    int **y,
    int **f,
    int *out_len
    );
