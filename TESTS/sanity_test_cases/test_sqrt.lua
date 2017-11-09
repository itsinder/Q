-- SANITY TEST
-- ## Problem: Square a whole number and then take out its square root, the result must be same.
-- ## Using Q.seq & Q.sqrt to solve a problem

-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- Creating a vector
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 46000} )
  -- TODO Get square root of natural number above 46000 (approx)
  -- Creating another vector which is square of the vector a
  local b = Q.vvmul(a, a)
  -- Finding square root of the elements of the series b
  local c = Q.sqrt(b)
  -- Expected Outcome
  --========================================
  local d = Q.vveq(a, c)
  assert(Q.sum(d):eval():to_num() == a:length())
--=======================================
end

--======================================

return tests
