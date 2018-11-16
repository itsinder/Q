local Q = require 'Q'
local wt_benefit = require 'Q/ML/DT/lua/wt_benefit'


--[[
variable explanation
f	- feature vector (type lVector)
g	- target/goal feature (type lVector)
n_T     - number of instances classified as negative (tails) in goal/target vector
n_H     - number of instances classified as positive (heads) in goal/target vector
]]
local function calc_benefit(
  f,
  g,
  n_T,
  n_H
  )
  -- START: Check parameters
  --assert(type(n_T) == "Scalar")
  --assert(type(n_H) == "Scalar")
  assert(n_T >= 0)
  assert(n_H >= 0)
  assert(type(g) == "lVector")
  assert(type(f) == "lVector")
  -- STOP: Check parameters

  --[[
  TODO: steps to follow in benefit calculation
  1. count intervals --> f', h0, h1 = Q.cntinterval(f, g)
  2. calculate benefit --> b = Q.wtbnfit(h0, h1, n_T, n_H)
  3. get max benefit --> b', _, i = Q.max(b)
  return b', f[i]
  ]]

  local benefit = -math.huge
  local split_point = nil

  -- sort f in ascending order and g in drag along
  -- before sort, clone the vectors
  local f_clone = f:clone()
  local g_clone = g:clone()
  Q.sort2(f_clone, g_clone, 'asc')

  -- counters for goal values
  local C = {}
  C[0] = 0
  C[1] = 0

  local n = (n_T + n_H)
  local i = 0

  while i < n do
    local f_val = f_clone:get_one(i):to_num()
    local g_val = g_clone:get_one(i):to_num()
    C[g_val] = C[g_val] + 1
    i = i + 1
    while i < n  do
      local fi_val = f_clone:get_one(i):to_num()
      local gi_val = g_clone:get_one(i):to_num()
      if fi_val ~= f_val then
        break
      end
      C[gi_val] = C[gi_val] + 1
      i = i + 1
    end
    local f_val_benefit = wt_benefit(C[0], C[1], (n_T - C[0]), (n_H - C[1]))
    if f_val_benefit > benefit then
      benefit = f_val_benefit
      split_point = f_val
    end
  end
  return benefit, split_point
end

return calc_benefit