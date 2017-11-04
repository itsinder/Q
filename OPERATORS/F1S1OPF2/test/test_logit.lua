-- FUNCTIONAL STRESS
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
tests.t1 = function() 
  local x = Q.mk_col( {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8}, "F8")
  local y = Q.logit(x):eval()
--[[
  print("=START x =========")
  Q.print_csv(x, nil, "")
  print("=STOP  x==========")
  print("=START y =========")
  Q.print_csv(y, nil, "")
  print("=STOP  y==========")
  local z = Q.vvdiv(Q.exp(x), Q.vsadd(Q.exp(x), 1)):eval()
  print("=START z =========")
  Q.print_csv(z, nil, "")
  print("=STOP  z==========")
  assert(Q.vvseq(y, z, 0.01))
  print("====++++++========")
  print(Q.logit(x))
  print(Q.vvdiv(Q.exp(x), Q.vsadd(Q.exp(x), 1)))
--]]
  assert(Q.vvseq(Q.logit(x), Q.vvdiv(Q.exp(x), Q.vsadd(Q.exp(x), 1)), 0.01))
end
return tests
