local Q = require 'Q'

local T = {}

local function inner_loop(X, y, beta)
  local Xbeta = Q.mvmul(X, beta)
  local p = Q.logit(Xbeta)
  local w = Q.logit2(Xbeta)
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
  local b_col = Q.Column({field_type = "F8", write_vector = true})
  b_col:put_chunk(#b, b)
  b_col:eov()
  b = b_col
  for i = 1, #A do
    local Ai_col = Q.Column({field_type = "F8", write_vector = true})
    Ai_col:put_chunk(#A[i], A[i])
    Ai_col:eov()
    A[i] = Ai_col
  end
  local beta_new_sub_beta = Q.posdef_linear_solver(A, b)
  local beta_new = Q.vvadd(beta_new_sub_beta, beta)
  return beta_new
end

local function outer_loop(X, y, iters)
  X[#X + 1] = Q.const({ val = 1, len = y:length(), qtype = 'F8' })
  local beta = Q.const({ val = 0, len = #X, qtype = 'F8' })
  for i = 1, iters do
    beta = inner_loop(X, y, beta)
  end
  return beta
end

local function package_betas(betas)
  local function append_1(x)
    -- TODO: this is awful
    local x_with_1 = {}
    x_size, x_chunk = x:chunk(-1)
    for i = 1, x_size do
      x_with_1[i] = x_chunk[i-1]
    end
    x_with_1[x_size + 1] = 1
    x_col = Column({field_type = "F8", write_vector = true})
    x_col:put_chunk(x_size + 1, x_with_1)
    x_col:eov()
    return x_col
  end

  local function get_prob(x, i)
    x = append_1(x)
    local denom = 1
    for _, beta in pairs(betas) do
      denom = denom + Q.sum(Q.vvmul(x, beta))
    end

    local num = 1
    if i < #betas then
      num = math.exp(Q.sum(Q.vvmul(x, betas[i])))
    end

    return num / denom
  end

  local function get_class(x)
    x = append_1(x)

    local max = 0
    local max_i = #betas
    for i = 1, #betas - 1 do
      local val = Q.sum(Q.vvmul(beta, x))
      if val > max then
        max = val
        max_i = i
      end
    end

    return max_i
  end

  return get_class, get_prob
end

local function train_multinomial(X, y, classes, iters)
  local out_betas = {}
  for i = 1, #classes - 1 do
    -- TODO: vvec should be replaced by Q.vseq when it is available
    local vvec = Q.const({ val = classes[i], len = y:length(), qtype = 'F8' })
    out_betas[i] = outer_loop(X, Q.vveq(y, vvec), iters)
  end
  return out_betas, package_betas(out_betas)
end
T.train_multinomial = train_multinomial
require('Q/q_export').export('train_multinomial_logistic_regression', train_multinomial)

local function train_binary(X, y, iters)
  out_betas, get_class, get_prob = train_multinomial(X, y, {0, 1}, iters)

  return out_betas[1], get_class, function(x) return get_prob(x, 2) end
end
T.train_binary = train_binary
require('Q/q_export').export('train_binary_logistic_regression', train_binary)

return T
