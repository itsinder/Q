local Q = require 'Q'
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
os.exit()
--[[
q s_to_f T1 f1 'val=[10]:fldtype=[I4]'
q s_to_f T1 f2 'val=[12]:fldtype=[I4]'
q f1f2opf3 T1 f1 f2 '+' f3
q pr_fld T1 f3 


--]]