-- SANITY TEST
-- ## Problem: Reciprocal of the reciprocal is the number itself.
-- ## Using reciprocal to justify the concept.

-- Library Calls
local Q = require 'Q'
local Scalar = require 'libsclr' -- TODO Remove this. Ask Indrajeet
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  local x = Q.rand( { lb = 1, ub = 10, qtype = "F4", len = 10 })
  -- 1/(1/x) = x
  assert(Q.vvseq(
             Q.reciprocal(
               Q.reciprocal(x)
             ),
             x,
	     Scalar.new(0.01, "F4")
           )
         )
  print("Succeeded in test reciprocal t1")
end
tests.t2 = function ()
  local qtypes = { "F4", "F8" }
  for k, qtype in ipairs(qtypes) do 
    local x = Q.rand( { lb = 1000000, ub = 10000000, qtype = qtype, len = 1000000 })
    -- 1/(1/x) = x
    assert(Q.vvseq(
             Q.reciprocal(
               Q.reciprocal(x)
             ),
             x,
	     Scalar.new(0.01, "F4"),
             { mode = "ratio" }
           )
         )
    print("Succeeded in test reciprocal t2")
  end
end
--======================================
return tests

