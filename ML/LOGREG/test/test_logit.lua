-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q        = require 'Q'
local Scalar   = require 'libsclr'
local lr_logit = require 'Q/ML/LOGREG/lua/lr_logit'
local qconsts  = require 'Q/UTILS/lua/q_consts'

local tests = {}
tests.t1 = function()
  local tolerance = 0.0001
  len = 2*qconsts.chunk_size + 17
  local z = Q.rand( { lb = 0.1, ub = 0.9, qtype = "F8", len = len } )
  local t3_a = Q.logit(z):eval()
  local t4_a = Q.logit2(z):eval()
  local t3_b, t4_b = lr_logit(z)
  assert(Q.vvseq(t3_a, t3_a, Scalar.new(tolerance, "F4")))
  assert(Q.vvseq(t3_b, t3_b, Scalar.new(tolerance, "F4")))
  print("Test t1 succeeded")
  -- Q.print_csv({z, t3_a, t4_a, t3_b, t4_b}); os.exit()
end
return tests
