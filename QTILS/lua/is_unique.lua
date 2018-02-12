-- local Q = require 'Q'
local sort = (require "Q/OPERATORS/SORT/lua/sort").sort
local is_next_eq = (require "Q/OPERATORS/F_TO_S/lua/_f_to_is").is_next_eq

local Scalar = require 'libsclr'
local qc  = require 'Q/UTILS/lua/q_core'
local ffi = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local T = {} 
local function is_unique(x)

  assert(x and type(x) == "lVector")
  if ( x:get_meta("is_unique") ) then return true end
  if ( x:set_meta("sort_order") ~= "asc" ) then 
    asssert(nil, "NOT IMPLEMENTED")
  end
  local a, b =  Q.is_next_eq(x):eval()
  local is_uq = not a 
  x:set_meta("is_uniqe", is_uq)
  return is_uq
  --================================================
end
T.is_unique = is_unique
require('Q/q_export').export('is_unique', is_unique)
return T
