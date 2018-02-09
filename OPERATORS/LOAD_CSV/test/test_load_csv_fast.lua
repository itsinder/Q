local ffi = require "ffi"
ffi.cdef([[
void *memset(void *s, int c, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
size_t strlen(const char *str);
typedef struct {
   char *fpos;
   void *base;
   unsigned short handle;
   short flags;
   short unget;
   unsigned long alloc;
   unsigned short buffincrement;
} FILE;
void * malloc(size_t size);
void free(void *ptr);
FILE *fopen(const char *path, const char *mode);
int fclose(FILE *stream);
int fwrite(void *Buffer,int Size,int Count,FILE *ptr);
int fflush(FILE *stream);
int
load_csv_fast(
    const char * const q_data_dir,
    const char * const infile,
    uint32_t nC,
    uint64_t *ptr_nR,
    const char ** fldtypes, /* [nC] */
    bool is_hdr, /* [nC] */
    bool * const is_load, /* [nC] */
    bool * const has_nulls, /* [nC] */
    uint64_t * const num_nulls, /* [nC] */
    char ***ptr_out_files,
    char ***ptr_nil_files,
    /* Note we set nil_files and out_files only if below == NULL */
    char *str_for_lua,
    size_t sz_str_for_lua,
    int *ptr_n_str_for_lua 
    );
]])

-- TODO: Put this back later ffi.new = nil 


local function load_csv_fast_C()

  x = ffi.load("./load_csv_fast.so")
  local n_str_for_lua = ffi.C.malloc(ffi.sizeof("int"))
  n_str_for_lua = ffi.cast("int *", n_str_for_lua)
  n_str_for_lua[0] = 0

  nC = 5
  local fldtypes = ffi.C.malloc(nC * ffi.sizeof("char *"))
  fldtypes = ffi.cast("const char **", fldtypes)
  
  local is_load = ffi.C.malloc(nC * ffi.sizeof("bool"))
  is_load = ffi.cast("bool *", is_load)

  local has_nulls = ffi.C.malloc(nC * ffi.sizeof("bool"))
  has_nulls = ffi.cast("bool *", has_nulls)  
  
  for i = 1, nC do
    -- TODO Do not hard code 4 below 
    fldtypes[i-1] = ffi.C.malloc(4 * ffi.sizeof("char"))
    fldtypes[i-1] = ffi.cast("const char *", fldtypes[i-1])
  end
  fldtypes[0] = "I8"
  fldtypes[1] = "SC"
  fldtypes[2] = "I4"
  fldtypes[3] = "SC"
  fldtypes[4] = "F8"

  is_load[0] = true
  is_load[1] = false
  is_load[2] = true
  is_load[3] = false
  is_load[4] = true

  has_nulls[0] = false
  has_nulls[1] = false
  has_nulls[2] = false
  has_nulls[3] = false
  has_nulls[4] = false

  local num_nulls = ffi.C.malloc(ffi.sizeof("uint64_t"))
  num_nulls = ffi.cast("uint64_t *", num_nulls)

  local out_files = nil
  local nil_files = nil 

  local sz_str_for_lua = 2048

  local str_for_lua = ffi.C.malloc(sz_str_for_lua)
  str_for_lua = ffi.cast("char *", str_for_lua)
  ffi.copy(str_for_lua, "01234567890123456789012345678901234567890123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");

  data_dir = "/home/subramon/local/Q/data/"
  infile = "/home/subramon/WORK/Q/TESTS/AB1/data/eee_1.csv"

  local nR = ffi.C.malloc(ffi.sizeof("uint64_t"))
  local is_hdr = true

  local status = x.load_csv_fast(data_dir, infile, nC, nR, fldtypes,
  is_hdr, is_load, has_nulls, num_nulls, out_files, nil_files,
  str_for_lua, sz_str_for_lua, n_str_for_lua);
  print(status)

end

niter = 10000
for i = 1, niter do
  load_csv_fast_C()
  print("iter = ", i)
end
