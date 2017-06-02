local Q = require 'Q'
local posdef_solver = require 'Q/OPERATORS/AX_EQUALS_B/lua/posdef_linear_solver'

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
  b = Q.mk_col(b)
  for i = 1, #A do
    A[i] = Q.mk_col(A[i])
  end
  local beta_new_sub_beta = posdef_solver(A, b)
  local beta_new = Q.vvadd(beta_new_sub_beta, beta)
  return beta_new
end

local function do_regression(X, y, iters)
  X[#X + 1] = Q.const_F8(1, y:length())
  local beta = Q.const_F8(0, #X)
  for i = 1, iters do
    beta = inner_loop(X, y, beta)
  end
  return beta
end
