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
-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata")
-- Loads the CSV file and stores in the Q internal format
--
-- returns : table containing list of files for each column defined in metadata.
--           If any error was encountered during load operation then negative status code
-- ----------------

-- validate meta-data & create vector + null vector for each of the file being created
local c = ffi.load("load_csv.so")


function load( csv_file_path, metadata, load_global_settings)
   local col_count = 0 --each field in the metadata represents one column in csv file
   local col_num_nil = {}
   assert( valid_file(csv_file_path),"Please make sure that csv_file_path is correct")
   assert( path.getsize(csv_file_path) ~= 0, "File should not be empty")
   validate_meta(metadata)
   --TODO unhard code
   -- TODO Put nils for columns that you do not want to load 
   local column_list = {
      Column{field_type="I4", write_vector=true, filename="_i4"},
      Column{field_type="F4", write_vector=true, filename="_f4"}
   }
   -- mmap function here
   f_map = ffi.gc( c.f_mmap(csv_file_path, false), c.f_munmap)
   assert(f_map.status == 0 , "Mmap failed")
   local X = ffi.cast("char *", f_map.ptr_mmapped_file)
   local nX = tonumber(f_map.ptr_file_size)
   assert (nX > 0, "File cannot be empty")
   local  xidx = 0;
   local bufsz = 8
   --TODO bufsize should be calculated from c data
   --TODO note double for SC type, SV max length in meta data
   local buf = ffi.gc(c.malloc(bufsz), c.free)
   local cbuf = ffi.gc(c.malloc(1024), c.free)
   local ncols = #metadata
   local rowidx = 0
   local colidx = 0

   while true do
      local is_last_col
      if ( colidx == (ncols-1) ) then
         is_last_col = true;
      else
         is_last_col = false;
      end
      xidx = tonumber( c.get_cell(X, nX, xidx, is_last_col, buf, bufsz)  )

      assert(xidx > 0 , "Index has to be valid")
      print(rowidx, colidx, ffi.string(buf))
      -- TODO figure out c function based on meta data
      -- TODO check status of c function
      -- TODO if column_list[colidx] == nil then continue end 
      if ( colidx == 0 ) then
         c.txt_to_I4(buf, 10, cbuf);
      else 
         c.txt_to_F4(buf, cbuf);
      end
      -- print(tonumber(cbuf))
      column_list[colidx+1]:put_chunk(1, cbuf)
      if ( is_last_col ) then
         rowidx = rowidx + 1
         colidx = 0;
      else
         colidx = colidx + 1 
      end

      if ( xidx >= nX ) then  break end
   end
   for i =1, #column_list do
      column_list[i]:eov()
   end
   print("Completed successfully")
   -- TODO create list and return that , not this
  dbg = require ("debugger")
  dbg() 
   return column_list

end

-- load( "gm1d1.csv" , dofile("gm1.lua"), nil)
