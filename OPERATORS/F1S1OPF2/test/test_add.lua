-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
require('Q/UTILS/lua/cleanup')()
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c2 = Q.vsadd(c1, Scalar.new(10, "I8"))
  local c3 = Q.mk_col( {11,12,13,14,15,16,17,18}, "I4")
  -- local opt_args = { opfile = "" }
  -- c2:eval(); Q.print_csv(c2, opt_args)
  local sum = Q.sum(Q.vveq(c2, c3)):eval():to_num()
  assert(sum == c1:length(), "Length Mismatch, Expected : " .. c1:length() .. ", Actual: " .. sum)
end
return tests
