-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar = require 'libsclr'
local lr_logit = require 'Q/ML/LOGISTIC_REGRESSION/lua/lr_logit'

local tests = {}
tests.t1 = function()
  local tolerance = 0.0001
  local z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 4 } )
  local t3_a = Q.logit(z):eval()
  local t4_a = Q.logit2(z):eval()
  local t3_b, t4_b = lr_logit(z)
  assert(Q.vvseq(t3_a, t3_a, Scalar.new(tolerance, "F4")))
  assert(Q.vvseq(t3_b, t3_b, Scalar.new(tolerance, "F4")))
  print("Test t1 succeeded")
end
return tests
