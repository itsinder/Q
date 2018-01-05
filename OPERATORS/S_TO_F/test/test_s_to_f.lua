-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local tests = {}
tests.t1 = function()
  local z
  z = Q.const( { val = 5, qtype = "I4", len = 10 }):eval()
  z = Q.rand( { lb = 100, ub = 200, seed = 1234, qtype = "I4", len = 10 }):eval()
  z = Q.seq( {start = -1, by = 5, qtype = "I4", len = 10} ):eval()
  --=======================================
end
return tests
