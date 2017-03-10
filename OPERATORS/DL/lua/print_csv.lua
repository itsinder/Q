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
local dbg = require("debugger")
require "load"
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
extern int
I4_to_txt(
const int32_t * const in,
const char * const fmt,
char *X,
size_t nX
);
extern int
F4_to_txt(
const float * const in,
const char * const fmt,
char *X,
size_t nX
);
]])
local dbg = require("debugger")
local c = ffi.load("load_csv.so")
function print_csv(column_list, filter, opfile)
   --TODO check that all are of same length and exist. If static type then
   --repeat
   --TODO check that c_type to txt exists
   assert(type(column_list) == "table")
   local max_length = column_list[1]:length()
   for i = 1, #column_list do
      assert(type(column_list[i]) == "Column" or type(column_list[i]) == "Vector")
      assert(column_list[i]:length() == max_length, "All columns/vectors should have the same length")
   end
   local lb = 0; local ub = 0
   local where = ""
   if filter ~= nil then
      -- dbg()
      assert(type(filter) == "table", "Filter must be a table")
      -- lb is inclusive, ub is exclusive
      lb = filter.lb
      ub = filter.ub
      where = filter.where
      if ( where ) then
         assert(type(where) == "Column" or type(where) == "Vector")
         assert(where:fldtype() == "B1")
      end
      if ( lb ) then
         lb = assert(tonumber(lb))
         assert(lb >= 0)
      else
         lb = 0;
      end
      if ( ub ) then
         ub = assert(tonumber(ub))
         assert(ub > lb )
         assert(ub <= max_length)
      else
         ub = max_length
      end
   else
      lb = 0
      ub = max_length
   end
   local bufsz = 1024
   local cbuf = c.malloc(bufsz) -- TODO alloc max of all field type
   local buf  = c.malloc(bufsz) -- TODO
   local num_cols = #column_list
   local num_rows = column_list[1]:length()
   local file = nil
   if opfile ~= nil and opfile ~= "" then
      file = io.open(opfile, "w+")
      io.output(file)
   end
   lb = lb + 1 -- for Lua style indexing
   for rowidx = lb, ub do
      --Column filter comes here
      -- dbg()
      if where == nil or where:get_element(rowidx -1 ) ~= ffi.NULL then
         -- print(rowidx, where:get_element(rowidx))
         for colidx = 1, num_cols do
            local col = column_list[colidx]
            cbuf = col:get_element(rowidx-1)
            if cbuf == ffi.NULL then
               c.sprintf(buf, "%s", "\"\"");
            else
               if colidx == 1 then
                  status = c.I4_to_txt(cbuf,"",  buf, bufsz)
               else
                  status = c.F4_to_txt(cbuf,"",  buf, bufsz)
               end
               assert(status == 0)

            end
            if ( colidx > 1 )  then
               io.write(",")
            end
            io.write(ffi.string(buf))
         end
         io.write("\n")
      end
   end
   if file then
      io.close(file)
   end
end
filter = {}
--filter.lb = 0
--filter.ub = 4
--print_csv(load( "gm1d1.csv" , dofile("gm1.lua")), filter)

local t = load( "gm2d1.csv" , dofile("gm2.lua"))
filter.where = t[3]
-- dbg()
t[3] = nil
print_csv(t, filter)
