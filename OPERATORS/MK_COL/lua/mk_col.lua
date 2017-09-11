local Q       = require 'Q/q_export'
local err     = require 'Q/UTILS/lua/error_code'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'   
local qc      = require 'Q/UTILS/lua/q_core'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'

local MAXIMUM_LUA_NUMBER = 9007199254740991
local MINIMUM_LUA_NUMBER = -9007199254740991


local mk_col = function (input, qtype)
  assert(input,  err.INPUT_NOT_TABLE)
  assert(type(input) == "table", "Input to mk_col must be a table")
  assert(#input > 0, "table has no entries")
  assert( qconsts.qtypes[qtype] ~= nil, err.INVALID_COLUMN_TYPE)
  local width = assert(qconsts.qtypes[qtype]["width"], err.NULL_WIDTH_ERROR)
  -- Does not support SC or SV
  assert((( qtype == "I1" )  or ( qtype == "I2" )  or ( qtype == "I4" )  or 
          ( qtype == "I8" )  or ( qtype == "F4" )  or ( qtype == "F8" ) ),
  err.INVALID_COLUMN_TYPE)
  -- TODO: Support B1 and SC in future
  -- To do - check max and min value in qtype
  assert(qconsts.qtypes[qtype].max, "max value of qtype nil " .. err.INVALID_COLUMN_TYPE)
  assert(qconsts.qtypes[qtype].min, "min value of qtype nil " .. err.INVALID_COLUMN_TYPE)
  
  for k,v in ipairs(input) do 
    assert(type(v) == "number",
    "Error in index " .. k .. " - " .. err.INVALID_DATA_ERROR)
    --print("v = "..string.format("%18.0f",v))
    -- TODO: Should this be < or <=, > or >= 
    assert(v >= MINIMUM_LUA_NUMBER, err.INVALID_LOWER_BOUND) 
    assert(v <= MAXIMUM_LUA_NUMBER, err.INVALID_UPPER_BOUND) 
    assert(v >= qconsts.qtypes[qtype].min, err.INVALID_LOWER_BOUND) 
    assert(v <= qconsts.qtypes[qtype].max, err.INVALID_UPPER_BOUND)
  end
  --if field_type ~= "SC" then width=nil end
  local col = Column{
    field_type=qtype, 
    write_vector=true,
    nn=false }
          
  local ctype =  assert(qconsts.qtypes[qtype].ctype, g_err.NULL_CTYPE_ERROR)
  local length = table.getn(input)
  local length_in_bytes = col:sz() * length
  local chunk = assert(ffi.new(ctype .. "[?]", length, input),g_err.FFI_NEW_ERROR)
  col:put_chunk(length, chunk)
  col:eov()
  return col
end

return require('Q/q_export').export('mk_col', mk_col)
