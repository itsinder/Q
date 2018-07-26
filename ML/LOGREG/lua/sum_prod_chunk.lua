local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

function sum_prod_chunk(X, w)
  local A = {}
  local status

  for i, X_i in pairs(X) do
    A[i] = {}
    local temp = Q.vvmul(X_i, w)
    for j, X_j in pairs(X) do
      A[i][j] = Q.sum(Q.vvmul(X_j, temp))
    end
  end

  repeat
    for i = 1, #X do
      for j = 1, #X do
        status = A[i][j]:next()
      end
    end
  until not status

  for i = 1, #X do
    for j = 1, #X do
      A[i][j] = A[i][j]:value() -- get the value evaluated
    end
  end

  return A
end
return sum_prod_chunk
