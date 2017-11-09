local Q       = require 'Q/q_export'
local err     = require 'Q/UTILS/lua/error_code'
local lVector = require 'Q/RUNTIME/lua/lVector'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'

local MAXIMUM_LUA_NUMBER = 9007199254740991
local MINIMUM_LUA_NUMBER = -9007199254740991


local mk_col = function (input, qtype, nn_input)
  assert(input,  err.INPUT_NOT_TABLE)
  assert(type(input) == "table", err.INPUT_NOT_TABLE)
  assert(#input > 0, "Input table has no entries")
  local has_nulls = false
  if ( nn_input ) then 
    assert(type(nn_input) == "table", err.INPUT_NOT_TABLE)
    assert(#nn_input == #input)
    has_nulls = true
  end
  
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

  local ctype =  assert(qconsts.qtypes[qtype].ctype, g_err.NULL_CTYPE_ERROR)
  local table_length = table.getn(input)
  local length_in_bytes = nil
  local chunk = nil
  
  
  local col = lVector{ qtype=qtype, gen = true, has_nulls = has_nulls}
    
  for k, v in ipairs(input) do
    local v_nn = nil
    if ( type(v) == "Scalar" ) then 
      -- all is well. Nothing more to do 
    elseif ( type(v) == "number" )  then
      v = assert(Scalar.new(v, qtype))
    elseif ( type(v) == "boolean" )  then
      v = assert(Scalar.new(v, qtype))
    else 
      assert(nil, "Error in index " .. k .. " - " .. err.INVALID_DATA_ERROR)
    end
     if ( nn_input ) then 
       local v = nn_input[k]
       assert(type(v) == "boolean")
       v_nn = Scalar.new(v, "B1")
     end
    col:put1(v, v_nn)
  end
  col:eov()
  return col
end

return require('Q/q_export').export('mk_col', mk_col)
