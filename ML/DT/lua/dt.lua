local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local calc_benefit = require 'Q/ML/DT/lua/benefit'
local chk_params = require 'Q/ML/DT/lua/chk_params'

local dt = {}

--[[
variable description
T	- table of m lVectors of length n, representing m features
g	- goal/target lVector of length n
alpha	- minimum benefit value of type Scalar 
n_N	- number of instances classified as negative in goal/target vector
n_P	- number of instances classified as positive in goal/target vector
best_k	- index of the feature f' in T for which maximum benefit is observed
best_sf - feature point from f' where maximun benefit is observed
best_bf - maximum benefit value
bf	- benefit value for each feature f
sf	- feature point from f for which benefit value bf is observed

D	- Decision Tree Table having below fields
{ 
  n_N,		-- number of negative instances
  n_P,		-- number of positive instances
  feature,	-- feature index for the split
  threshold,	-- feature point/value for the split
  left,		-- left decision tree
  right 	-- right decision tree
}
]]
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
  if ( best_bf > alpha:to_num() ) then 
    local x = Q.vsleq(T[best_k], best_sf)
    local T_L = {}
    local T_R = {}
    D.feature = best_k
    D.threshold = best_sf
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


local function check_dt(
  D	-- prepared decision tree
  )
  -- Verify the decision tree
  local status = true
  -- TODO: implementation pending
  return status
end


local function predict(
  D,	-- prepared decision tree
  x	-- a table with test features
  )
  assert(type(D) == 'table')
  assert(type(x) == 'table')

  while true do
    if D.left == nil and D.right == nil then
      return D.n_P, D.n_N
    else
      local val = x[D.feature]
      if val > D.threshold then
        print("Right Subtree")
        D = D.right
      else
        print("Left Subtree")
        D = D.left
      end
    end
  end
end


local function print_dt(
  D	-- prepared decision tree
  )
  if not D then
    return
  end
  print(D.feature, D.threshold, D.n_P, D.n_N)
  print_dt(D.left)
  print_dt(D.right)
end


dt.make_dt = make_dt
dt.predict = predict
dt.check_dt = check_dt
dt.print_dt = print_dt

return dt
