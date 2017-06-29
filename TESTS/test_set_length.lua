require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local dbg = require 'Q/UTILS/lua/debugger'


local x_len = 65537
for iter = 1, 100 do 
  local y = Q.rand({ lb = 0, ub = 1, seed = 1234, qtype = "I1", len = x_len } )
  local c1 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
  local c2 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F8", len = x_len } )
  X = {c1, c2}
  local beta = Q.rand({ lb = 0, ub = 1, qtype = "F8", len = 2 } )

  local A = {}
  local chk = 0
  local chk2 = 0
  lengths = {}
  for i, _ in ipairs(X) do 
    lengths[i] = 0
  end

  for i, X_i in ipairs(X) do
    if ( iter == 1 ) then 
      assert(X_i:length() == 0 )
    else
      assert(X_i:length() > 0 )
    end
    A[i] = {}
    for j, X_j in ipairs(X) do
      print("iter/i/j/len Xj = ", iter, i, j, X_j:length())
      A[i][j] = Q.sum(Q.vvmul(X_i, X_j))
      chk = A[i][j]:eval()
      if ( i > 1 ) then 
        chk2 = A[i][j]:eval()
        assert ( chk2 == chk )
      end
    end
  end
end
print("Completed " .. arg[0])
os.exit()

