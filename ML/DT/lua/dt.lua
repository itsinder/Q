local Q = require 'Q'
local Scalar = require 'libsclr'
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
  --[[
  print("===================INFO START================")
  print("Input table length = " .. tostring(#T))
  print("Feature length = " .. tostring(T[1]:length()))
  print("Length of target/goal = " .. tostring(g:length()))
  print("===================INFO END================")
  ]]
  local m, n, ng = chk_params(T, g, alpha)
  local D = {} 
  local cnts = Q.numby(g, ng):eval()
  local n_N, n_P
  n_N = cnts:get_one(0)
  if ng == 1 then
    n_P = Scalar.new(0, "I8")
    --n_P = 0
  else
    n_P = cnts:get_one(1)
  end
  D.n_N = n_N
  D.n_P = n_P
  if n_N:to_num() == 0 or n_P:to_num() == 0 then
    return D
  end
  local best_bf, best_sf, best_k
  --print("Benefit for each feature is")
  for k, f in pairs(T) do
    local bf, sf = calc_benefit(f, g, n_N, n_P)
    --print(bf .. "\t" .. sf .. "\t" .. k)
    if ( best_bf == nil ) or ( bf > best_bf ) then
      best_bf = bf
      best_sf = sf
      best_k = k
    end
  end
  --print("Max benefit and respecitve feature is ")
  --print(best_bf .. "\t" .. best_sf .. "\t" .. best_k)
  if ( best_bf > alpha:to_num() ) then 
    local x = Q.vsleq(T[best_k], best_sf):eval()
    local T_L = {}
    local T_R = {}
    D.feature = best_k
    D.threshold = best_sf
    for k, f in pairs(T) do 
      T_L[k] = Q.where(f, x):eval()
      T_R[k] = Q.where(f, Q.vnot(x)):eval()
    end
    g_L = Q.where(g, x):eval()
    D.left  = make_dt(T_L, g_L, alpha)
    g_R = Q.where(g, Q.vnot(x)):eval()
    D.right = make_dt(T_R, g_R, alpha)
  end
  return D
end


local function check_dt(
  D	-- prepared decision tree
  )
  -- Verify the decision tree
  local status = true

  if D.left then
    assert(D.right)
  else
    assert(D.right == nil)
  end

  if D.left == nil and D.right == nil then
    assert(D.feature == nil)
    assert(D.threshold == nil)
    assert(D.n_N ~= nil)
    assert(D.n_P ~= nil)
  end

  if D.left and D.right then
    assert(D.n_N == D.left.n_N + D.right.n_N)
    assert(D.n_P == D.left.n_P + D.right.n_P)
  end
  -- TODO: Add more checks
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
      if val:to_num() > D.threshold then
        --print("Right Subtree")
        D = D.right
      else
        --print("Left Subtree")
        D = D.left
      end
    end
  end
end


local function print_dt(
  D,		-- prepared decision tree
  f,		-- file_descriptor
  col_name	-- table of column names of train dataset
  )
  if not D then
    return
  end
  local label = "\"n_N=" .. tostring(D.n_N) .. ", n_P=" .. tostring(D.n_P)
  --print(D.feature, D.threshold, D.n_P, D.n_N)
  if D.left and D.right then
    label = label .. "\\n" .. col_name[D.feature] .. "<=" .. D.threshold .. "\""
    local left_label = "\"n_N=" .. tostring(D.left.n_N) .. ", n_P=" .. tostring(D.left.n_P)
    local right_label = "\"n_N=" .. tostring(D.right.n_N) .. ", n_P=" .. tostring(D.right.n_P)
    if D.left.feature then
      left_label = left_label .. "\\n" .. col_name[D.left.feature] .. "<=" .. D.left.threshold
    end
    left_label = left_label .. "\""
    if D.right.feature then
      right_label = right_label .. "\\n" .. col_name[D.right.feature] .. "<=" .. D.right.threshold
    end
    right_label = right_label .. "\""
    f:write(label .. " -> " .. left_label .. "\n")
    --print(label .. " -> " .. left_label)
    f:write(label .. " -> " .. right_label .. "\n")
    --print(label .. " -> " .. right_label)

    print_dt(D.left, f, col_name)
    print_dt(D.right, f, col_name)
  else
    -- No tree available
  end
end


dt.make_dt = make_dt
dt.predict = predict
dt.check_dt = check_dt
dt.print_dt = print_dt

return dt
