local Q = require 'Q'
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'

local function inner_loop(X, y, beta)
  local Xbeta = Q.mvmul(X, beta)
  local p, w = Q.logit(Xbeta)
  local ysubp = Q.vvsub(y, p)
  local A = {}
  local b = {}
  for i, X_i in ipairs(X) do
    A[i] = {}
    b[i] = Q.sum(Q.vvmul(X_i, ysubp))
    for j, X_j in ipairs(X) do
      A[i][j] = Q.sum(Q.vvmul(X_i, Q.vvmul(w, X_j)))
    end
  end
  local b_col = Column({field_type = "F8", write_vector = true})
  b_col:put_chunk(#b, b)
  b_col:eov()
  b = b_col
  for i = 1, #A do
    local Ai_col = Column({field_type = "F8", write_vector = true})
    Ai_col:put_chunk(#A[i], A[i])
    Ai_col:eov()
    A[i] = Ai_col
  end
  local beta_new_sub_beta = Q.posdef_linear_solver(A, b)
  local beta_new = Q.vvadd(beta_new_sub_beta, beta)
  return beta_new
end

local function do_regression(X, y, iters)
  X[#X + 1] = Q.const({ val = 1, len = y:length(), qtype = 'F8' })
  local beta = Q.const({ val = 0, len = #X, qtype = 'F8' })
  for i = 1, iters do
    beta = inner_loop(X, y, beta)
  end
  return beta
end
