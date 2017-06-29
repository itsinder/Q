require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local dbg = require 'Q/UTILS/lua/debugger'


for i = 1, 1 do 
  local x_len = 65537
  local y = Q.rand({ lb = 0, ub = 1, seed = 1234, qtype = "I1", len = x_len } )
  local c1 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
  local c2 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
  X = {c1, c2}
  local beta = Q.rand({ lb = 0, ub = 1, qtype = "F8", len = 2 } )
  beta:eval()

  -- dbg()
  local Xbeta = Q.cmvmul(X, beta)
  Xbeta:eval()
end
print("Completed " .. arg[0])
os.exit()
