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
n_T	- number of instances classified as negative (tails) in goal/target vector
n_H	- number of instances classified as positive (heads) in goal/target vector
best_k	- index of the feature f' in T for which maximum benefit is observed
best_sf - feature point from f' where maximun benefit is observed
best_bf - maximum benefit value
bf	- benefit value for each feature f
sf	- feature point from f for which benefit value bf is observed

D	- Decision Tree Table having below fields
{ 
  n_T,		-- number of negative (tails) instances
  n_H,		-- number of positive (heads) instances
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

  --[[
  local ng_verify
  local sum = Q.sum(g):eval()
  if sum:to_num() > 0 then
    ng_verify = 2
  else
    ng_verify = 1
  end

  local minval, _, _ = Q.min(g):eval()
  local maxval, _, _ = Q.max(g):eval()
  if maxval > minval then
    ng_verify = maxval:to_num() - minval:to_num() + 1
  elseif maxval == minval then
    ng_verify = maxval:to_num() + 1
  end
  if ng_verify ~= ng then
    print(Q.sum(g):eval())
    print(ng_verify, ng)
    print(minval, maxval)
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    Q.print_csv(g)
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
  end
  assert(ng_verify == ng)
  ]]

  local cnts = Q.numby(g, ng):eval()
  local n_T, n_H
  n_T = cnts:get_one(0)
  if ng == 1 then
    n_H = Scalar.new(0, "I4")
  else
    n_H = cnts:get_one(1)
  end
  D.n_T = n_T
  D.n_H = n_H
  if n_T:to_num() == 0 or n_H:to_num() == 0 then
    return D
  end
  local best_bf, best_sf, best_k
  for k, f in pairs(T) do
    local bf, sf = calc_benefit(f, g, n_T, n_H)
    if ( best_bf == nil ) or ( bf > best_bf ) then
      best_bf = bf
      best_sf = sf
      best_k = k
    end
  end
  -- print("Max benefit and respecitve feature is ")
  -- print(best_bf .. "\t" .. best_sf .. "\t" .. best_k)
  if ( best_bf > alpha:to_num() ) then 
    local x = Q.vsleq(T[best_k], best_sf):eval()
    local T_L = {}
    local T_R = {}
    D.feature = best_k
    D.threshold = best_sf
    D.benefit = best_bf
    for k, f in pairs(T) do 
      T_L[k] = Q.where(f, x):eval()
    end
    g_L = Q.where(g, x):eval()
    D.left  = make_dt(T_L, g_L, alpha)
    for k, f in pairs(T) do
      T_R[k] = Q.where(f, Q.vnot(x)):eval()
    end
    g_R = Q.where(g, Q.vnot(x)):eval()
    D.right = make_dt(T_R, g_R, alpha)
  end
  return D
end


local function node_count(
  D
  )
  local n_count = 1
  if D.left then
    n_count = n_count + node_count(D.left)
  end
  if D.right then
    n_count = n_count + node_count(D.right)
  end
  return n_count
end


local function check_dt(
  D	-- prepared decision tree
  )
  -- Verify the decision tree
  local status = true
  if not D then
    return status
  end

  if D.left then
    assert(D.right)
  else
    assert(D.right == nil)
  end

  if D.left == nil and D.right == nil then
    assert(D.feature == nil)
    assert(D.threshold == nil)
    assert(D.n_T ~= nil)
    assert(D.n_H ~= nil)
  end

  if D.left and D.right then
    assert(D.n_T == D.left.n_T + D.right.n_T)
    assert(D.n_H == D.left.n_H + D.right.n_H)
  end

  -- TODO: Add more checks

  check_dt(D.left)
  check_dt(D.right)
end


local function predict(
  D,	-- prepared decision tree
  x	-- a table with test features
  )
  assert(type(D) == 'table')
  assert(type(x) == 'table')

  while true do
    if D.left == nil and D.right == nil then
      return D.n_H, D.n_T
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
  local label = "\"n_T=" .. tostring(D.n_T) .. ", n_H=" .. tostring(D.n_H)
  --print(D.feature, D.threshold, D.n_H, D.n_T)
  if D.left and D.right then
    label = label .. "\\n" .. col_name[D.feature] .. "<=" .. D.threshold .. "\\n" .. "benefit=" .. D.benefit .. "\""
    local left_label = "\"n_T=" .. tostring(D.left.n_T) .. ", n_H=" .. tostring(D.left.n_H)
    local right_label = "\"n_T=" .. tostring(D.right.n_T) .. ", n_H=" .. tostring(D.right.n_H)
    if D.left.feature then
      left_label = left_label .. "\\n" .. col_name[D.left.feature] .. "<=" .. D.left.threshold .. "\\n" .. "benefit=" .. D.left.benefit
    end
    left_label = left_label .. "\""
    if D.right.feature then
      right_label = right_label .. "\\n" .. col_name[D.right.feature] .. "<=" .. D.right.threshold .. "\\n" .. "benefit=" .. D.right.benefit
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
dt.node_count = node_count

return dt
