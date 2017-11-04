-- SANITY TEST
-- ## Problem: Reciprocal of the reciprocal is the number itself.
-- ## Using reciprocal to justify the concept.

-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()

-- Creating a vector
local x = Q.rand( { lb = 1, ub = 10000000, qtype = "I4", len = 100000 })
--print(x:eval():length())
--print(Q.sum(Q.vveq(Q.reciprocal(Q.reciprocal(x)), x)):eval())

-- Expected Outcome
--========================================
assert(Q.sum(Q.vveq(Q.reciprocal(Q.reciprocal(x)), x):eval()) == x:eval():length(), "Vector Mismatch")

end
--======================================
return tests

