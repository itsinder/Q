-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
-- local dbg = require 'Q/UTILS/lua/debugger'
for iter = 1, 1000 do 
  local c1 = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 65537 } )
  local c2 = Q.sum(c1)
  c2:eval()
end
local status = pcall(Q.sum, 123)
assert(status == false)
print("SUCCESS for " .. arg[0])
os.exit()
--=========================================
