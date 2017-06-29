local Q = require 'Q'
local dbg = require 'Q/UTILS/lua/debugger'


for i = 1, 1000 do 
  local x_len = 65537
  local y = Q.rand({ lb = 0, ub = 1, seed = 1234, qtype = "I1", len = x_len } )
  local c1 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
  local c2 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
  X = {c1, c2}
  local beta = Q.rand({ lb = 0, ub = 1, qtype = "F8", len = 2 } )
  beta:eval()

  local Xbeta = Q.cmvmul(X, beta)
  local p = Q.logit(Xbeta)
  local w = Q.logit2(Xbeta)
  local ysubp = Q.vvsub(y, p)
  local temp = ysubp:eval()
  --========================= 

  local A = {}
  local b = {}
  for i, X_i in ipairs(X) do
    A[i] = {}
    b[i] = Q.sum(Q.vvmul(X_i, ysubp))
    for j, X_j in ipairs(X) do
      A[i][j] = Q.sum(Q.vvmul(X_i, Q.vvmul(w, X_j)))
      A[i][j]:eval()
    end
    b[i]:eval()
  end
  print("Iteration ", i)
end
print("SUCCESS for ", arg[0])
os.exit()
