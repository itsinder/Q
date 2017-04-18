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


function mk_col(input, qtype)
  assert( input ~= nil,g_err.INPUT_NOT_TABLE)
  assert( g_valid_types[qtype] ~= nil,g_err.INVALID_COLUMN_TYPE)
  local width = g_qtypes[qtype]["width"]
  assert(width ~= nil, g_err.NULL_WIDTH_ERROR)
  -- Does not support SC or SV
  assert(qtype ~= "SC",g_err.INVALID_COLUMN_TYPE)
  assert(qtype ~= "SV",g_err.INVALID_COLUMN_TYPE)
  -- To do - check max and min value in qtype
  
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
  local chunk = ffi.new(ctype .. "[?]", length)
  
  -- below commented code - if we want to use malloc instead of new
  --[[
  local chunk = ffi.gc(ffi.C.malloc(length_in_bytes), ffi.C.free)
  chunk = ffi.cast(ctype.. "*", chunk)
  ffi.C.memset(chunk, 0, length_in_bytes)
  --]]
  
  -- Need to check the maximum and minimum value of qtype
  -- maximum and minimum value of each qtype can be stored in global lua table
  
  for k,v in ipairs(input) do 
    assert(type(v) == "number","Error in index "..k.." - "..g_err.INVALID_DATA_ERROR)
    chunk[k-1] = v 
  end
  
  col:put_chunk(length, chunk)
  col:eov()
  print("Successfully loaded ")
  return col
end
