local Q = require 'Q'
-- local dbg = require 'Q/UTILS/lua/debugger'
for iter = 1, 1000 do 
  local c1 = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 65537 } )
  local c2 = Q.sum(c1)
  c2:eval()
end
print("Completed " .. arg[0]); os.exit()
os.exit()
--=========================================
