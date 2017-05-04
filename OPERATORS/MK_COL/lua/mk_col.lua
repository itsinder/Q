local error_code = require 'error_code'

-- local Dictionary = require 'dictionary'
local Column = require 'Column'   
local ffi = require "ffi"
ffi.cdef
[[ 
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);
]]

local MAXIMUM_LUA_NUMBER = 9007199254740991
local MINIMUM_LUA_NUMBER = -9007199254740991
local max = {
  I1 = 127, 
  I2 = 32767, 
  I4 = 2147483647, 
  I8 = 9223372036854775807,
  F4 = 3.4 * math.pow(10,38),
  F8 = 1.7 * math.pow(10,308)
  }

local min = {
  I1 = -128, 
  I2 = -32768, 
  I4 = -2147483648, 
  I8 = -9223372036854775808,
  F4 = -3.4 * math.pow(10,38),
  F8 = -1.7 * math.pow(10,308)
  }


return function (input, qtype)
  assert( input ~= nil,g_err.INPUT_NOT_TABLE)
  assert(type(input) == "table", "Input to mk_col must be a table")
  assert(#input > 0, "table has no entries")
  assert( g_valid_types[qtype] ~= nil,g_err.INVALID_COLUMN_TYPE)
  local width = assert(g_qtypes[qtype]["width"], g_err.NULL_WIDTH_ERROR)
  -- Does not support SC or SV
  assert(qtype ~= "B1", "TODO: To be implemented")
  assert(qtype ~= "SC",g_err.INVALID_COLUMN_TYPE)
  assert(qtype ~= "SV",g_err.INVALID_COLUMN_TYPE)
  -- To do - check max and min value in qtype
  assert(max[qtype] ~= nil,"max value of qtype nil "..g_err.INVALID_COLUMN_TYPE)
  assert(min[qtype] ~= nil,"min value of qtype nil "..g_err.INVALID_COLUMN_TYPE)
  
  for k,v in ipairs(input) do 
    assert(type(v) == "number",
    "Error in index " .. k .. " - " .. g_err.INVALID_DATA_ERROR)
    --print("v = "..string.format("%18.0f",v))
    -- TODO: Should this be < or <=, > or >= 
    assert(v >= MINIMUM_LUA_NUMBER, g_err.INVALID_LOWER_BOUND) 
    assert(v <= MAXIMUM_LUA_NUMBER, g_err.INVALID_UPPER_BOUND) 
    assert(v >= min[qtype], g_err.INVALID_LOWER_BOUND) 
    assert(v <= max[qtype], g_err.INVALID_UPPER_BOUND)
  end
  
  local col = Column{
    field_type=qtype, 
    field_size=width, 
    write_vector=true,
    nn=false }
          
  local ctype =  assert(g_qtypes[qtype].ctype, g_err.NULL_CTYPE_ERROR)
  local length = table.getn(input)
  -- VIJAY: Check has been mader earlier assert(length>0, g_err.INPUT_LENGTH_ERROR)
  local length_in_bytes = width * length
  local chunk = ffi.new(ctype .. "[?]", length, input)
  col:put_chunk(length, chunk)
  col:eov()
  -- print("Successfully loaded ") Use log info for such things
  return col
end
