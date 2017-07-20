

typedef struct _file_cleanup_struct {
    char file_name[200];
    int clean;
} file_cleanup_struct;



typedef struct _mmap_rec_type {

  char file_name[255+1];
    void *map_addr;
    size_t map_len;
    int is_persist;
    int status;
} MMAP_REC_TYPE;

typedef struct _vec_rec_type {
  char field_type[3+1];
  uint32_t field_size;
  uint32_t chunk_size;

  uint32_t num_elements;
  uint32_t num_in_chunk;
  uint32_t chunk_num;


  char file_name[255+1];
  char *map_addr;
  size_t map_len;

  char *ret_addr;
  size_t ret_len;

  uint32_t is_persist;
  bool is_nascent;
  int status;
  int is_memo;
  bool is_read_only;
  char *chunk;
} VEC_REC_TYPE;

extern int
txt_to_SC(
      char * const X,
      char *out,
      size_t sz_out
      );


extern int
rand_file_name(
    char *buf,
    size_t bufsz
    );


extern int
f_munmap(
    MMAP_REC_TYPE *ptr_mmap
);

extern int
bytes_to_bits(
    uint8_t *in,
    uint64_t n,
    uint64_t *out
    );


extern int
SC_to_txt(
    char * const in,
    uint32_t width,
    char * X,
    size_t nX
    );

extern int
get_bit(
    unsigned char *x,
    int i
);


extern int
txt_to_F4(
      const char * const X,
      float *ptr_out
      );





  extern int
    bin_search_I2(
          const int16_t *X,
          uint64_t nX,
          int16_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;



extern int
F4_to_txt(

    float * in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern int64_t
get_file_size(
 const char * const file_name
 );


extern int
I4_to_txt(

    int32_t * in,
    const char * const fmt,
    char *X,
    size_t nX
    );



extern int
chk_field_type(
    const char * const field_type
    );
extern int
vec_nascent(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_size,
    uint32_t chunk_size
    );
extern int
vec_materialized(
    VEC_REC_TYPE *ptr_vec,
    const char *const file_name,
    bool is_read_only
    );
extern int
vec_check(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_free(
    VEC_REC_TYPE *ptr_vec
    );
extern bool
file_exists (
    const char * constfilename
    );
extern int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char *addr,
    uint64_t idx,
    uint32_t len
    );
extern int
vec_eov(
    VEC_REC_TYPE *ptr_vec,
    bool is_read_only
    );
extern int
vec_get(
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx,
    uint32_t len
    );
extern int
is_eq_I4(
    void *X,
    int val
    );


extern int
txt_to_I2(
      const char * const X,
      int16_t *ptr_out
      );





  extern int
    bin_search_I8(
          const int64_t *X,
          uint64_t nX,
          int64_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;


extern int
txt_to_F8(
      const char * const X,
      double *ptr_out
      );





  extern int
    bin_search_F8(
          const double *X,
          uint64_t nX,
          double key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;


extern int
txt_to_I4(
      const char * const X,
      int32_t *ptr_out
      );





  extern int
    bin_search_F4(
          const float *X,
          uint64_t nX,
          float key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;

extern int
write_bits_to_file(
    FILE * fp,
    unsigned char *src,
    int length,
    int file_size
);


extern int
txt_to_I8(
      const char * const X,
      int64_t *ptr_out
      );

extern int
bits_to_bytes(
    uint64_t *in,
    uint8_t *out,
    uint64_t n_out
    );

extern int
file_cleanup(
    file_cleanup_struct* data
);


extern void
c_free(
    void *X
);


extern uint64_t
mix_UI8(
    uint64_t a
    );





  extern int
    bin_search_I1(
          const int8_t *X,
          uint64_t nX,
          int8_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;


extern MMAP_REC_TYPE *
f_mmap(
   char * const file_name,
   bool is_write
);


extern int
buf_to_file(
   const char *addr,
   size_t size,
   size_t nmemb,
   const char * const file_name
);


extern int
I2_to_txt(

    int16_t * in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern size_t
get_cell(
    char *X,
    size_t nX,
    size_t xidx,
    bool is_last_col,
    char *buf,
    size_t bufsz
    );


extern int
F8_to_txt(

    double * in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern uint32_t
mix_UI4(
    uint32_t a
    );


extern int
rs_mmap(
 const char *file_name,
 char **ptr_mmaped_file,
 size_t *ptr_file_size,
 bool is_write
 );


extern int
c_copy(
   void *dst_addr,
   void *src_addr,
   size_t num_in_chunk,
   size_t num_to_copy,
   size_t field_size
);






  extern int
    bin_search_I4(
          const int32_t *X,
          uint64_t nX,
          int32_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        )
    ;


extern int
txt_to_I1(
      const char * const X,
      int8_t *ptr_out
      );


extern int
I1_to_txt(

    int8_t * in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern int
I8_to_txt(

    int64_t * in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern bool
is_valid_chars_for_num(
      const char * X
      );
