gcc -g $QC_FLAGS \
  test.c \
  vec.c \
  mmap.c \
  txt_to_I4.c \
  is_valid_chars_for_num.c \
  rand_file_name.c \
  get_file_size.c \
  mix_UI8.c \
  mix_UI4.c \
  buf_to_file.c \
  -I./inc/ \
  -I../../../UTILS/gen_inc/ \
  -I../../../OPERATORS/LOAD_CSV/gen_inc/ \
  -I./gen_inc/ \
  -shared -o libtest.so

gcc -g $QC_FLAGS \
  cmem.c \
  -I./inc/ \
  -I./gen_inc/ \
  -shared -o libcmem.so
