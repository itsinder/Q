local Q = require 'Q'
local utils = require 'Q/UTILS/lua/util'
local calc_benefit = require 'Q/ML/DT/lua/benefit'
local chk_params = require 'Q/ML/DT/lua/chk_params'

local dt = {}

local function make_dt(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  alpha -- Scalar, minimum benefit
  )
  local m, n, ng = chk_params(T, g, alpha)
  local D = {} 
  local cnts = Q.numby(g, ng):eval()
  local n_N = cnts:get_one(0)
  local n_P = cnts:get_one(1)
  local best_bf, best_sf, best_k
  for k, f in pairs(T) do 
    local bf, sf = calc_benefit(f, g, n_N, n_P)
    if ( best_bf == nil ) or ( bf > best_bf ) then
      best_bf = bf
      best_sf = sf
      best_k = k
    end
  end
  D.n_N = n_N
  D.n_P = n_P
  if ( best_bf > alpha ) then 
    local x = Q.vsleq(T[best_k], best_sf)
    local T_L = {}
    local T_R = {}
    D.feature = best_k
    D.threshold = best_sp
    for k, f in pairs(T) do 
      T_L[k] = Q.where(f, x)
      T_R[k] = Q.where(f, Q.vnot(x))
    end
    g_L = Q.where(g, x)
    g_R = Q.where(g, Q.vnot(x))
    D.left  = make_dt(T_L, g_L, alpha)
    D.right = make_dt(T_R, g_R, alpha)
  end
  return D
end


local function predict(
  D -- prepared decision tree
  X -- a table with test samples
  )
  assert(type(D) == 'table')
  assert(type(X) == 'table')

  local predicted_value = {}
  local n = utils.table_length(X)

  for i = 1, n do
    local x = X[i]
    while true do:
      if D.left == nil and D.right == nil then
        local decision = if D.n_P > D.n_N then 1 else 0 end
        predicted_value[i] = decision
        break
      elseif x[D.feature] > D.threshold then
        print("Right Subtree")
        D = D.right
      else
        print("Left Subtree")
        D = D.left
      end
    end
  end
  
  return predicted_value
end

dt.make_dt = make_dt
dt.predict = predict

return dt
