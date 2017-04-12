require 'globals'
require 'error_code'
require 'extract_fn_proto'

local ffi = require "ffi"
ffi.cdef
[[ 
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);
]]

local rootdir = os.getenv("Q_SRC_ROOT")
--print("***********",rootdir)
-- TODO this should be done in single loop; need way to differentiate "gen" types/code in global
local SC_to_txt = assert(extract_fn_proto(rootdir.."/OPERATORS/PRINT/src/SC_to_txt.c"))
local I1_to_txt = assert(extract_fn_proto(rootdir.."/OPERATORS/PRINT/gen_src/_I1_to_txt.c"))
local I2_to_txt = assert(extract_fn_proto(rootdir.."/OPERATORS/PRINT/gen_src/_I2_to_txt.c"))
local I4_to_txt = assert(extract_fn_proto(rootdir.."/OPERATORS/PRINT/gen_src/_I4_to_txt.c"))
local I8_to_txt = assert(extract_fn_proto(rootdir.."/OPERATORS/PRINT/gen_src/_I8_to_txt.c"))
local F4_to_txt = assert(extract_fn_proto(rootdir.."/OPERATORS/PRINT/gen_src/_F4_to_txt.c"))
local F8_to_txt = assert(extract_fn_proto(rootdir.."/OPERATORS/PRINT/gen_src/_F8_to_txt.c"))

ffi.cdef(SC_to_txt)
ffi.cdef(I1_to_txt)
ffi.cdef(I2_to_txt)
ffi.cdef(I4_to_txt)
ffi.cdef(I8_to_txt)
ffi.cdef(F4_to_txt)
ffi.cdef(F8_to_txt)

-- load print_csv so file
-- this file is created using compile_so for local testing
local print_csv_lib = ffi.load("print_csv.so")

function print_csv(column_list, filter, opfile)  
  
  assert(type(column_list) == "table",g_err.INPUT_NOT_TABLE)
  -- to do unit testing with columns of differet length
  local max_length = 0
  for i = 1, #column_list do
    assert(type(column_list[i]) == "Column" or type(column_list[i]) == "number", 
      g_err.INPUT_NOT_COLUMN_NUMBER)
      
    local is_column = type(column_list[i]) == "Column" 
    if is_column then
      --assert(column_list[i]:length() == max_length, "All columns should have the same length")
      assert(g_valid_types[column_list[i]:fldtype()] ~= nil, g_err.INVALID_COLUMN_TYPE)
      assert(g_qtypes[column_list[i]:fldtype()] ~= "B1", g_err.COLUMN_B1_ERROR)
      assert(g_qtypes[column_list[i]:fldtype()]["width"] ~= nil, g_err.NULL_WIDTH_ERROR)
      assert(g_qtypes[column_list[i]:fldtype()]["ctype"] ~= nil, g_err.NULL_CTYPE_ERROR)
      assert(g_qtypes[column_list[i]:fldtype()]["ctype_to_txt"] ~= nil, g_err.NULL_CTYPE_TO_TXT_ERROR)
      -- dictionary cannot be null in get_meta for SV data type
      if column_list[i]:fldtype() == "SV" then 
        assert(column_list[i]:get_meta("dir")~=nil,g_err.NULL_DICTIONARY_ERROR)
      end
      -- Take the maximum length of all columns
      local tmp = column_list[1]:length()
      if tmp > max_length then max_length = tmp end
      
    end
  end
  
  local lb = 0; local ub = 0
  local where
  if filter ~= nil then
    assert(type(filter) == "table", g_err.FILTER_NOT_TABLE_ERROR)
    lb = filter.lb
    ub = filter.ub
    where = filter.where
    if ( where ) then
      assert(type(where) == "Vector",g_err.FILTER_TYPE_ERROR)
      assert(where:fldtype() == "B1",g_err.FILTER_INVALID_FIELD_TYPE)
    end
    if ( lb ) then
      lb = assert(tonumber(lb))
      assert(lb >= 0,g_err.INVALID_LOWER_BOUND)
    else
      lb = 0;
    end
    if ( ub ) then
      ub = assert(tonumber(ub))
      assert(ub > lb ,g_err.UB_GREATER_THAN_LB)
      assert(ub <= max_length, g_err.INVALID_UPPER_BOUND)
    else
      ub = max_length
    end
  else
    lb = 0
    ub = max_length
  end
  
  -- TODO - remove hardcoding of 1024
  local bufsz = 1024
  local buf = ffi.gc(ffi.C.malloc(bufsz), ffi.C.free) 
  
  local num_cols = #column_list
  local file = nil
  if opfile ~= nil and opfile ~= "" then
    file = io.open(opfile, "w+")
    io.output(file)
  end
  
  lb = lb + 1 -- for Lua style indexing
  for rowidx = lb, ub do
    if where == nil or where:get_element(rowidx -1 ) ~= ffi.NULL then
      local result = ""
      for colidx = 1, num_cols do
        local temp
        local col = column_list[colidx]
        -- if input is scalar, assign scalar value
        if type(col) == "number" then 
          temp = col 
        else
          local cbuf = col:get_element(rowidx-1)          
          
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
              local dictionary = col:get_meta("dir")
              temp = dictionary:get_string_by_index(temp)
            end
          end
        end
        result = result..temp..","
      end
      -- remove last comma
      result = string.sub(result,1,-2)
      result = result.."\n"
      assert(io.write(result),g_err.INVALID_FILE_PATH)
    end
  end
  if file then
    io.close(file)
  end
  return true
end
