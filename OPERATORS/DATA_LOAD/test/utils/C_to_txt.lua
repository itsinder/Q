require 'globals'
require 'extract_fn_proto'

local ffi = require "ffi"
ffi.cdef
[[ 
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);
]]

-- TODO this should be done in single loop; need way to differentiate "gen" types/code in global
local SC_to_txt = assert(extract_fn_proto("../../PRINT/src/SC_to_txt.c"))
local I1_to_txt = assert(extract_fn_proto("../../PRINT/gen_src/_I1_to_txt.c"))
local I2_to_txt = assert(extract_fn_proto("../../PRINT/gen_src/_I2_to_txt.c"))
local I4_to_txt = assert(extract_fn_proto("../../PRINT/gen_src/_I4_to_txt.c"))
local I8_to_txt = assert(extract_fn_proto("../../PRINT/gen_src/_I8_to_txt.c"))
local F4_to_txt = assert(extract_fn_proto("../../PRINT/gen_src/_F4_to_txt.c"))
local F8_to_txt = assert(extract_fn_proto("../../PRINT/gen_src/_F8_to_txt.c"))

ffi.cdef(SC_to_txt)
ffi.cdef(I1_to_txt)
ffi.cdef(I2_to_txt)
ffi.cdef(I4_to_txt)
ffi.cdef(I8_to_txt)
ffi.cdef(F4_to_txt)
ffi.cdef(F8_to_txt)

local print_csv_lib = ffi.load("print_csv.so")

function convert_c_to_txt(col, rowidx)
  local temp=""
  local cbuf = col:get_element(rowidx-1)  
  local bufsz = 1024
  local buf = ffi.gc(ffi.C.malloc(bufsz), ffi.C.free) 
         
  if cbuf == ffi.NULL then
    temp = ""
  else
    local is_SC = col:fldtype() == "SC"    -- if field type is SC , then pass field size, else nil
    local is_SV = col:fldtype() == "SV"    -- if field type is SV , then get value from dictionary
    local field_size
    local second_arg
    -- if SC, then field_size is taken from size field, else it is 1024
    if is_SC == true then 
      field_size = col:sz()
      second_arg = field_size
    else 
      field_size = bufsz    
      second_arg = ""
    end
  
    local function_name = g_qtypes[col:fldtype()]["ctype_to_txt"]
    ffi.C.memset(buf, 0, bufsz)
    local status = print_csv_lib[function_name](cbuf, second_arg, buf, field_size )
    temp = ffi.string(buf)
    -- get SV data type from dictionary
    if is_SV == true then 
      temp = tonumber(temp)
      --assert(_G["Q_DICTIONARIES"]~=nil,g_err.NULL_DICTIONARY_ERROR)
      assert(col:get_meta("dir")~=nil,g_err.COLUMN_GET_META_ERROR)
      local dictionary = col:get_meta("dir")
      temp = dictionary:get_string_by_index(temp)
    end
  end
  return temp
end

