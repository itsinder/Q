-- SANITY TEST
-- ## Problem: Reciprocal of the reciprocal is the number itself.
-- ## Using reciprocal to justify the concept.

-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- Creating a vector
  local x = Q.rand( { lb = 1, ub = 10000000, qtype = "F4", len = 100000 })
  -- 1/(1/x) = x
  assert(Q.vvseq(
           Q.convert(
             Q.reciprocal(
               Q.reciprocal(x)
             ),
             {qtype = "F4"}
           ),
           x, 
           0.01
         )
       )
end
--======================================
return tests

