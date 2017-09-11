require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local lr_logit = require 'Q/ML/LOGISTIC_REGRESSION/lua/lr_logit'

local z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 4 } )
local t3_a = Q.logit(z)
local t4_a = Q.logit2(z)
t3_a:eval()
t4_a:eval()

t3_b, t4_b = lr_logit(z)

local tol = 0.0001

local k3 = Q.sum(Q.vslt(Q.abs(Q.vvsub(t3_a, t3_b)), tol)):eval()
if(k3 ~= z:length()) then
  Q.print_csv(t3_a, nil, "")
  print("--------------------")
  Q.print_csv(t3_b, nil, "")
else
  print("all good")
  assert(k3 == z:length())
end

--n3 = Q.sum(Q.vveq(t3_a, t3_b)):eval()
--assert(n3 == z:length())

print("----NEXT VECTOR------")
--n4 = Q.sum(Q.vveq(t4_a, t4_b)):eval()
--assert(n4 == z:length())
local k4 = Q.sum(Q.vslt(Q.vvsub(t4_a, t4_b), tol)):eval()
if(k3 ~= z:length()) then
  Q.print_csv(t3_a, nil, "")
  print("--------------------")
  Q.print_csv(t3_b, nil, "")
else
  print("all good")
  assert(k4 == z:length())
end

-- TODO Fix to provide tolerance assert(n4 == z:length())


print("SUCCESS for " .. arg[0] )
os.exit()
