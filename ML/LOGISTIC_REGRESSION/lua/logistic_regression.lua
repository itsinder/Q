local Q = require 'Q'
local ffi = require 'Q/UTILS/lua/q_ffi'

local T = {}

local function beta_step(X, y, beta)
  local Xbeta = Q.mv_mul(X, beta)
  local p = Q.logit(Xbeta)
  local w = Q.logit2(Xbeta)
  local ysubp = Q.vvsub(y, p)
ysubp:eval()
ysubp:set_name("ysubp")
  local temp = ysubp:meta()
for k, v in pairs(temp.base) do print(k, v) end
print("============")

  local A = {}
  local b = {}
  for i, X_i in ipairs(X) do
    A[i] = {}
    X_i:set_name("X" .. i)
    b[i] = Q.sum(Q.vvmul(X_i, ysubp)) 
    for j, X_j in ipairs(X) do
      A[i][j] = Q.sum(Q.vvmul(X_i, Q.vvmul(w, X_j)))
    end
  end

  for i = 1, #A do
print("START: evaluating b_" .. i)
    b[i]:eval()
print("STOP:  evaluating b_" .. i)
--[[
    for j = 1, #A[i] do
      A[i][j]:eval()
    end
--]]
  end
  print("beta_step: sum_prod eval done, EXITING")
  os.exit()

  b = Q.mk_col(b, "F8")
  for i = 1, #A do
    A[i] = Q.mk_col(A[i], "F8")
  end

  local beta_new_sub_beta = Q.posdef_linear_solver(A, b)
  local beta_new = Q.vvadd(beta_new_sub_beta, beta)

  return beta_new
end

local function package_betas(betas)
  local function append_1(x)
    -- TODO: this is awful
    local x_with_1 = {}
    x_size, x_chunk = x:chunk()
    for i = 1, x_size do
      x_with_1[i] = x_chunk[i-1]
    end
    x_with_1[x_size + 1] = 1
    --x_col = Column({field_type = 'F8', write_vector = true})
    x_col = lVector( { qtype = "F8", gen = true} )
    --x_col:put_chunk(x_size + 1, x_with_1)
    x_col:put_chunk(x_with_1, nil, x_size + 1)
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

  local function get_probs(X, i)
    X[#X + 1] = Q.const({ val = 1, len = y:length(), qtype = 'F8' })
    local denoms = Q.const({ val = 1, len = y:length(), qtype = 'F8' })
    for _, beta in pairs(betas) do
      denoms = Q.exp(Q.vvsum(Q.mv_mul(X, beta)))
    end

    local nums = Q.const({ val = 1, len = y:length(), qtype = 'F8' })
    if i < #betas then
      nums = Q.exp(Q.mv_mul(X, betas[i]))
    end

    return Q.vvdiv(nums, denoms)
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

  local function get_classes(X)
    X[#X + 1] = Q.const({ val = 1, len = X[1]:length(), qtype = 'F8' })
    X[#X]:eval()
    local vals = {}
    local len = 0
    for i = 1, #betas - 1 do
      val = Q.mv_mul(X, betas[i])
      len, val, _ = val:chunk()
      val = ffi.cast('double*', val)
      vals[i] = val
    end

    local classes = {}
    for i = 1, len do
      local max = 0
      local max_i = #betas
      for j = 1, #betas - 1 do
        local val = vals[j][i - 1]
        if val > max then
          max = val
          max_i = i
        end
      end

      classes[i] = max_i
    end

    X[#X] = nil
    classes = Q.mk_col(classes, 'F8')
    classes:eval()
    return classes
  end

  return get_class, get_prob, get_classes, get_probs
end
T.package_betas = package_betas
require('Q/q_export').export('package_logistic_regression_betas', package_betas)

local function make_trainer(X, y, classes)
  X[#X + 1] = Q.const({ val = 1, len = y:length(), qtype = 'F8' })
  X[#X]:eval()
  local betas = {}
  local ys = {}
  for i = 1, #classes - 1 do
    betas[i] = Q.const({ val = 0, len = #X, qtype = 'F8' })
    betas[i]:eval()
    local _, ytmp, _ = y:chunk()
    ytmp = ffi.cast('double*', ytmp)
    local ytab = {}
    for i = 1, y:length() do
      ytab[i] = 0
      if ytmp[i - 1] == classes[i] then
        ytab[i] = 1
      end
    end
    ys[i] = Q.mk_col(ytab, 'F8')
    ys[i]:eval()
  end

  local function step_betas()
    for i = 1, #betas do
      betas[i] = beta_step(X, ys[i], betas[i])
      betas[i]:eval()
    end
  end

  return betas, step_betas
end
T.make_trainer = make_trainer
require('Q/q_export').export('make_logistic_regression_trainer', make_multinomial_trainer)

return T
