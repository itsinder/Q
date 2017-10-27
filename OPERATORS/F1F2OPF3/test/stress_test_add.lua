-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local function foo (x)
  local y = Q.vvadd(x, x)
  return y
end

z = Q.const({val = 10, len = 10, qtype = "F8"})
for i = 1, 1000000 do 
--[[
  local z = foo(z) === THIS WORKS 
--]]
  z = foo(z) -- THIS BLOWS UP
  if ( ( i % 1000) == 0 ) then print("Iteration ", i) end
end

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
--[[
q s_to_f T1 f1 'val=[10]:fldtype=[I4]'
q s_to_f T1 f2 'val=[12]:fldtype=[I4]'
q f1f2opf3 T1 f1 f2 '+' f3
q pr_fld T1 f3 


--]]
