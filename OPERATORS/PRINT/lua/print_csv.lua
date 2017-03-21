package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

local ffi = require "ffi"
ffi.cdef
[[ 
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);
  int I1_to_txt(int8_t *in, const char * const fmt, char *X, size_t nX);
  int I2_to_txt(int16_t *in, const char * const fmt, char *X, size_t nX);
  int I4_to_txt(int32_t *in, const char * const fmt, char *X, size_t nX);
  int I8_to_txt(int64_t *in, const char * const fmt, char *X, size_t nX);

  int F4_to_txt(float *in, const char * const fmt, char *X, size_t nX);  
  int F8_to_txt(double *in, const char * const fmt, char *X, size_t nX);

  int SC_to_txt(char * const in, uint32_t width, char * X, size_t nX);  
]]

local c = ffi.load('print.so')
local q_c_print_lib = ffi.load("q_c_print_functions.so")

function print_csv(column_list, filter, opfile)    
  assert(type(column_list) == "table")
  local max_length = column_list[1]:length()
  for i = 1, #column_list do
    assert(type(column_list[i]) == "Column" or type(column_list[i]) == "number", 
      " input can be either Column or number")
      
    local is_column
    is_column = type(column_list[i]) == "Column" 
    if is_column then
      assert(column_list[i]:length() == max_length, "All columns should have the same length")
      assert(g_valid_types[column_list[i]:fldtype()] ~= nil, " column should be of valid type")
      assert(g_qtypes[column_list[i]:fldtype()] ~= nil, " column should be of valid type ")
      assert(g_qtypes[column_list[i]:fldtype()]["width"] ~= nil, " width of column cannot be nil ")
      assert(g_qtypes[column_list[i]:fldtype()]["ctype"] ~= nil, " ctype of column cannot be nil ")
      assert(g_qtypes[column_list[i]:fldtype()]["ctype_to_txt"] ~= nil, " ctype_to_txt of column \
        cannot be nil ")
    end
  end
  
  local lb = 0; local ub = 0
  local where
  if filter ~= nil then
    assert(type(filter) == "table", "Filter must be a table")
    lb = filter.lb
    ub = filter.ub
    where = filter.where
    if ( where ) then
      assert(type(where) == "Column" or type(where) == "Vector","Filter should be either Vector or Column")
      assert(where:fldtype() == "B1","Data type of Filter should be B1")
    end
    if ( lb ) then
      lb = assert(tonumber(lb))
      assert(lb >= 0,"lower bound in Filter should be greater than or equal to zero")
    else
      lb = 0;
    end
    if ( ub ) then
      ub = assert(tonumber(ub))
      assert(ub > lb ,"lower bound cannot be equal to or greater than upper bound")
      assert(ub <= max_length, "upper bound should be less than maximum length of column")
    else
      ub = max_length
    end
  else
    lb = 0
    ub = max_length
  end
  
  local bufsz = 1024
  local buf  = c.malloc(bufsz) -- TODO
  
  
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
            
            if is_SC == true then 
              field_size = col:sz()
              second_arg = field_size
            else 
              field_size = bufsz
              second_arg = ""
            end
            
            local function_name = g_qtypes[col:fldtype()]["ctype_to_txt"]
            c.memset(buf, 0, bufsz)
            local status = q_c_print_lib[function_name](cbuf, second_arg, buf, field_size )
            temp = ffi.string(buf)
          end
        end
        result = result..temp..","
      end
      result = string.sub(result,1,-2)
      result = result.."\n"
      io.write(result)
    end
  end
  if file then
    io.close(file)
  end  
end
