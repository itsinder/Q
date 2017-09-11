-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
local c3 = c1
c1 = 10
print(c1)
local c2 = Q.mk_col( {80,70,60,50,40,30,20,10}, "I4")
local z = Q.vvadd(c3, c2, { junk = "junk" } )
-- local dbg = require 'Q/UTILS/lua/debugger'
z:eval()
-- print(z:length())
Q.print_csv(z, { lb = 1, ub = 4} , "")
--==============
local w = Q.vveq(c3, c2)
w:eval()
print(w)

local status = pcall(Q.vveq, c3, 123)
assert(status == false)

print("Successfully completed")

require('Q/UTILS/lua/cleanup')()
os.exit()
--[[
q s_to_f T1 f1 'val=[10]:fldtype=[I4]'
q s_to_f T1 f2 'val=[12]:fldtype=[I4]'
q f1f2opf3 T1 f1 f2 '+' f3
q pr_fld T1 f3 


--]]
