require 'error_code'

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


function mk_col(input, qtype)
  assert( input ~= nil,g_err.INPUT_NOT_TABLE)
  assert( g_valid_types[qtype] ~= nil,g_err.INVALID_COLUMN_TYPE)
  local width = g_qtypes[qtype]["width"]
  assert(width ~= nil, g_err.NULL_WIDTH_ERROR)
  -- Does not support SC or SV
  assert(qtype ~= "SC",g_err.INVALID_COLUMN_TYPE)
  assert(qtype ~= "SV",g_err.INVALID_COLUMN_TYPE)
  -- To do - check max and min value in qtype
  assert(max[qtype] ~= nil,"max value of qtype nil "..g_err.INVALID_COLUMN_TYPE)
  assert(min[qtype] ~= nil,"min value of qtype nil "..g_err.INVALID_COLUMN_TYPE)
  
  for k,v in ipairs(input) do 
    assert(type(v) == "number","Error in index "..k.." - "..g_err.INVALID_DATA_ERROR)
    --print("v = "..string.format("%18.0f",v))
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
          
  local ctype =  g_qtypes[qtype]["ctype"]
  assert(ctype~= nil, g_err.NULL_CTYPE_ERROR)
  local length = table.getn(input)
  assert(length>0, g_err.INPUT_LENGTH_ERROR)
  local length_in_bytes = width * length
  local chunk = ffi.new(ctype .. "[?]", length, input)
  col:put_chunk(length, chunk)
  col:eov()
  print("Successfully loaded ")
  return col
end
