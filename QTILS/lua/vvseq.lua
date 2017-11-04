-- local Q = require 'Q'
local sub = (require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3").vvsub
local abs = (require "Q/OPERATORS/F1S1OPF2/lua/_f1s1opf2").abs
local vsgt = (require "Q/OPERATORS/F1S1OPF2/lua/_f1s1opf2").vsgt
local sum = (require "Q/OPERATORS/F_TO_S/lua/_f_to_s").sum
local prcsv = (require "Q/OPERATORS/PRINT/lua/print_csv")
local Scalar = require 'libsclr'

local qc  = require 'Q/UTILS/lua/q_core'
local ffi = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

-- TODO P1 
-- Should take relative difference not absolute difference
-- or provide an option to specify which one
local T = {} 
local function vvseq(x, y, s)

  assert(x and type(x) == "lVector")
  assert(y and type(y) == "lVector")
-- NOT a valid check  assert(x:fldtype() == y:fldtype())
  assert(is_base_qtype(x:fldtype()))
  assert(s)
  if ( ( type(s) == "number" ) or ( type(s) == "string") ) then 
    s = assert(Scalar.new(s, x:fldtype()))
  elseif ( type(s) == "Scalar" ) then 
    -- NOT a valid check assert(s:fldtype() == x:fldtype())
  else
    assert(nil, "bad type for scalar")
  end
  local sval = assert(tonumber(Scalar.to_str(s)))
  assert(sval >= 0)
  return(sum(vsgt(abs(sub(x, y)), s)):eval():to_num() == 0 )
  --================================================
end
T.vvseq = vvseq
require('Q/q_export').export('vvseq', vvseq)
return T
