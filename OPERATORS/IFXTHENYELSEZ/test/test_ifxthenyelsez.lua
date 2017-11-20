-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar = require 'libsclr' ; 

local tests = {}
tests.t1 = function()
  local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
  local y = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
  local z = Q.mk_col({-1, -2, -3, -4, -5, -6, -7}, "I4")
  local exp_w = Q.mk_col({1, -2, 3, -4, 5, -6, 7}, "I4")
  local w = Q.ifxthenyelsez(x, y, z)
  -- w:eval()
  -- Q.print_csv({w, exp_w, y, z}, nil, "")
  local n = Q.sum(Q.vveq(w, exp_w))
  local m = n:eval():to_num()
  assert(m == 7)
  print("Test t1 succeeded")
end
--==========================
tests.t2 = function()
  local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
  local y = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
  local z = Scalar.new("10", "I4")
  local w = Q.ifxthenyelsez(x, y, z)
  local n = Q.sum(Q.vseq(w, 10))
  -- w:eval()
  -- Q.print_csv({w, exp_w, y}, nil, "")
  local m = n:eval():to_num()
  assert(m == 3)
  print("Test t2 succeeded")
end
--===========================
tests.t3 = function()
  local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
  local y = Scalar.new("100", "I4")
  local z = Q.mk_col({-1, -2, -3, -4, -5, -6, -7}, "I4")
  local w = Q.ifxthenyelsez(x, y, z)
  local n = Q.sum(Q.vseq(w, 100))
  m = n:eval():to_num()
  assert(m == 4)
  -- w:eval()
  -- Q.print_csv({w, z}, nil, "")
  print("Test t3 succeeded")
end
--===========================
tests.t4 = function()
  local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
  local y = Scalar.new("100", "I4")
  local z = Scalar.new("-100", "I4")
  local w = Q.ifxthenyelsez(x, y, z)
  local n = Q.sum(Q.vseq(w, 100))
  m = n:eval():to_num()
  -- w:eval()
  -- Q.print_csv({w, x}, nil, "")
  assert(m == 4)
  print("Test t4 succeeded")
end
return tests
