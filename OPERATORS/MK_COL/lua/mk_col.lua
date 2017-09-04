local Q       = require 'Q/q_export'
local err     = require 'Q/UTILS/lua/error_code'
local Column  = require 'Q/RUNTIME/lua/lVector'
local qc      = require 'Q/UTILS/lua/q_core'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'

local MAXIMUM_LUA_NUMBER = 9007199254740991
local MINIMUM_LUA_NUMBER = -9007199254740991


local mk_col = function (input, qtype)
  assert(input,  err.INPUT_NOT_TABLE)
  assert(type(input) == "table", err.INPUT_NOT_TABLE)
  assert(#input > 0, "Input table has no entries")
  
  -- Does not support SC or SV
  assert((( qtype == "I1" )  or ( qtype == "I2" )  or ( qtype == "I4" )  or
          ( qtype == "I8" )  or ( qtype == "F4" )  or ( qtype == "F8" ) or ( qtype == "B1")),
  err.INVALID_COLUMN_TYPE)
  -- TODO: Support SC in future
  
  assert( qconsts.qtypes[qtype] ~= nil, err.INVALID_COLUMN_TYPE)
  
  local width = assert(qconsts.qtypes[qtype]["width"], err.NULL_WIDTH_ERROR)

  -- To do - check max and min value in qtype except B1
  if qtype ~= "B1" then
    assert(qconsts.qtypes[qtype].max, "max value of qtype nil " .. err.INVALID_COLUMN_TYPE)
    assert(qconsts.qtypes[qtype].min, "min value of qtype nil " .. err.INVALID_COLUMN_TYPE)
  end

  for k,v in ipairs(input) do
    assert(type(v) == "number",
    "Error in index " .. k .. " - " .. err.INVALID_DATA_ERROR)
    --print("v = "..string.format("%18.0f",v))
    if qtype == "B1" then
      --check if number is either 0 or 1
      assert((v == 1 or v == 0), err.INVALID_B1_VALUE)    
    else
      -- TODO: Should this be < or <=, > or >=
      assert(v >= MINIMUM_LUA_NUMBER, err.INVALID_LOWER_BOUND)
      assert(v <= MAXIMUM_LUA_NUMBER, err.INVALID_UPPER_BOUND)
      assert(v >= qconsts.qtypes[qtype].min, err.INVALID_LOWER_BOUND)
      assert(v <= qconsts.qtypes[qtype].max, err.INVALID_UPPER_BOUND)
    end
  end
  --if field_type ~= "SC" then width=nil end
  --[[local col = Column{
    field_type=qtype,
    write_vector=true,
    nn=false }
  ]]
  
  local ctype =  assert(qconsts.qtypes[qtype].ctype, g_err.NULL_CTYPE_ERROR)
  local table_length = table.getn(input)
  local length_in_bytes = nil
  local chunk = nil
  
  local col = Column{
    qtype=qtype,
    gen = true,
    num_elements = table_length,
    has_nulls=false }  
    
  
  if qtype == "B1" then
    -- Allocate memory (multiple of 8bytes)
    length_in_bytes = math.ceil(table_length/64)*8
    chunk = cmem.new(length_in_bytes)
    ffi.fill(chunk, length_in_bytes, 0)
    local casted = ffi.cast(ctype .. "*", chunk)

    -- Copy values to allocated chunk
    -- TODO: Look for bit operation in Lua or can we use C code (shift operator) instead of below arithmetic
    for k, v in ipairs(input) do
      if v == 1 then
        local char_idx = math.floor((k-1) / 8)
        local bit_idx = (k-1) % 8
        local char_value = casted + char_idx
        local result = tonumber( qc.set_bit(char_value, bit_idx) )        
        --print("Set bit result: " ..tostring(result))
        --local index = math.floor((k-1)/64)
        --chunk[index] = chunk[index] + math.pow(2, k-1)
      end
    end
  else
    length_in_bytes = col:field_size() * table_length
    chunk = cmem.new(length_in_bytes)
    ffi.fill(chunk, length_in_bytes, 0)
    local casted = ffi.cast(ctype .. "*", chunk)
    
    for k, v in ipairs(input) do
      casted[k-1] = v
    end
    --chunk = assert(ffi.new(ctype .. "[?]", table_length, input),g_err.FFI_NEW_ERROR)
  end
  col:put_chunk(chunk, nil, table_length)
  col:eov()
  return col
end

return require('Q/q_export').export('mk_col', mk_col)
