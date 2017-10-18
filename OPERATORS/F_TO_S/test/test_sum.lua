-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
-- local dbg = require 'Q/UTILS/lua/debugger'
for iter = 1, 100 do 
  local c1 = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 65537 } )
  local c2 = Q.sum(c1)
  c2:eval()
end

local status = pcall(Q.sum, 123)
assert(status == false)

n = 1048576+17
y = Q.seq({start = 1, by = 1, qtype = "I4", len = n })
z = Q.sum(y):eval()
if ( z ~= (n * (n+1) / 2 ) ) then 
  print("FAILURE for " .. arg[0])
else
  print("SUCCESS for " .. arg[0])
end
  
require('Q/UTILS/lua/cleanup')()
os.exit()
--=========================================
