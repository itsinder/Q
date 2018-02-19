local T = {} 
local function clone(x)
  local Q   = require 'Q/q_export'
  local qc  = require 'Q/UTILS/lua/q_core'
  local ffi = require 'Q/UTILS/lua/q_ffi'
  assert(x)
  assert(type(x) == "lVector")
  -- TODO: support Q.clone() for non_eov vector, document the reason/explaination
  assert(x:is_eov(), "Vector must be materialized before cloning")
  return x:clone()
  --================================================
end
T.clone = clone
require('Q/q_export').export('clone', clone)
return T
