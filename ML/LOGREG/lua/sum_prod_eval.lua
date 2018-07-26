local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

function sum_prod_eval(X, w)
  local A = {}

  for i, X_i in pairs(X) do
    A[i] = {}
    local temp = Q.vvmul(X_i, w)
    for j, X_j in pairs(X) do
      A[i][j] = Q.sum(Q.vvmul(X_j, temp)):eval()
    end
  end

  return A
end
return sum_prod_eval
