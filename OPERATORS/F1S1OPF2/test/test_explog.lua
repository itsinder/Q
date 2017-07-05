-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
-- local dbg = require 'Q/UTILS/lua/debugger'
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
local z = Q.vsadd(c1, 10 , "junk")
z:eval()
Q.print_csv(z, nil, "")
--===========================
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "F8")
local z = Q.exp(c1)
z:eval()
Q.print_csv(z, nil, "")
--===========================
local c1 = Q.mk_col( {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8}, "F8")
local z = Q.logit(c1)
z:eval()
Q.print_csv(z, nil, "")
--===========================
local c1 = Q.mk_col( {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8}, "F8")
local z = Q.logit2(c1)
z:eval()
Q.print_csv(z, nil, "")

for i = 1, 1000 do
  local z = Q.sum(Q.logit2(Q.logit(Q.log(Q.exp(Q.rand({ lb = 10, ub = 20, seed = 1234, qtype = "F4", len = 65537 } ))))))
  z:eval()
  print("Iteration ", i)
end

--===========================
print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
--[[
q s_to_f T1 f1 'val=[10]:fldtype=[I4]'
q s_to_f T1 f2 'val=[12]:fldtype=[I4]'
q f1f2opf3 T1 f1 f2 '+' f3
q pr_fld T1 f3 


--]]
