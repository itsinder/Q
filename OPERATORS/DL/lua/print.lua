package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

_G["Q_DATA_DIR"] = "./"
_G["Q_META_DATA_DIR"] = "./"
_G["Q_DICTIONARIES"] = {}

-- local Vector_Wrapper = require 'vector_wrapper'
require "validate_meta"
require 'globals'
require 'parser'
require 'dictionary'
local Vector = require 'Vector'
local Column = require 'Column'
-- require 'q_c_functions'
require 'pl'
require 'utils'
local ffi = require "ffi"
ffi.cdef([[
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
typedef struct {void* ptr_mmapped_file; size_t ptr_file_size; int status; } mmap_struct;
mmap_struct* f_mmap(const char* file_name, bool is_write);
int f_munmap(mmap_struct* map);
FILE *fopen(const char *path, const char *mode);
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
txt_to_F4(
const char *X,
float *ptr_out
);
extern int
txt_to_I4(
const char *X,
int base,
int32_t *ptr_out
);


]])

local c = ffi.load("load_csv.so")
function print(column_list, filter)

   --TODO check that all are of same length and exist. If static type then
   --repeat
   --TODO check that c_type to txt exists
   assert(type(column_list) == "table")
   for i = 1, #column_list do
      assert(type(column_list[i]) == "Column")
   end

   local bufsz = 1024
   local cbuf = c.malloc(bufsz) -- TODO
   local buf  = c.malloc(bufsz) -- TODO
   local num_cols = #column_list
   local num_rows = column_list[1].length()
   if filter_lb and filter_ub then
      lb = filter_lb
      ub = filter_ub
   else
      lb = 1
      ub = num_rows+1
   end

   for rowidx = lb, ub do
      --Column filter comes here
      for colidx = 1, num_cols+1 do
         local c = column_list[colidx]
         cbuf = c:get_element(rowidx-1)
         if cbuf. == ffi.NULL then
            c.sprintf(buf, "%s", "\"\"");
         else
            status = I4_to_txt(cbuf, buf, bufsz)
            assert(status == 0)
         end
         if ( rowidx == 1 )  then
            fprintf(ofp, "%s", buf)
         else
            fprintf(ofp, ",%s", buf)
         end
      end
      fprintf(ofp, "\n")
   end
end
