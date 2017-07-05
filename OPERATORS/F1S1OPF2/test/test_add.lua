-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local dbg = require 'Q/UTILS/lua/debugger'
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
local z = Q.vsadd(c1, 10 )
local z2= Q.vsadd(c1, { value = 10, qtype = "I8"} )
z:eval()
Q.print_csv(z, nil, "")
--===========================
-- local c1 = Q.mk_col( {1,2,1,2,1,2,1,2}, "I8")
-- local z = Q.vseq(c1, { value = 2 }
-- z:eval()
-- Q.print_csv(z, nil, "")
--===========================
print("=================================")
local c2 = Q.sum(Q.vseq(c1, 4))
c2:eval()
print(c2:eval())
local status = Q.vseq( 4, c1)
assert(status == false)
--===========================
local status = Q.vsmul(2, Q.mk_col({1, 2, 3}, "F8"))
assert(status == false)
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
