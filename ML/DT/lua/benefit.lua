local Q = require 'Q'

--[[
variable explanation
n_N_R   - number of negatives on right
n_P_R   - number of positives on right
n_N_L	- number of negatives on left
n_P_L	- number of positives on left
]]
-- TODO: export this function as Q's function --> Q.wtbnfit
local function weighted_benefit(
  n_N_L,
  n_P_L,
  n_N_R,
  n_P_R
  )
  -- determine total number on left and right
  local n_L = n_N_L + n_P_L -- total number on left
  local n_R = n_N_R + n_P_R -- total number on right

  -- determine left and right weightage
  local w_L = n_L / ( n_L + n_R ) -- weightage on left
  local w_R = n_R / ( n_L + n_R ) -- weightage on right

  -- payout offerd if bets heads or tails
  local o_N = ( ( n_P_L + n_P_R ) / ( n_N_L + n_N_R ) ) -- payout for betting tail
  local o_P = ( ( n_N_L + n_N_R ) / ( n_P_L + n_P_R ) ) -- payout for betting head

  -- calculate benefit
  local b_P_L = o_P * ( n_P_L / n_L ) + ( n_N_L / n_L ) * (-1) -- benefit of betting head on left
  local b_N_L = o_N * ( n_N_L / n_L ) + ( n_P_L / n_L ) * (-1) -- benefit of betting tail on left
  local b_P_R = o_P * ( n_P_R / n_R ) + ( n_N_R / n_R ) * (-1) -- benefit of betting head on right
  local b_N_R = o_N * ( n_N_R / n_R ) + ( n_P_R / n_R ) * (-1) -- benefit of betting tail on right

  local b_L = math.max(b_P_L, b_N_L) -- benefit on left
  local b_R = math.max(b_P_R, b_N_R) -- benefit on right

  local b = ( w_L * b_L ) + ( w_R * b_R ) -- total benefit

  return b
end



--[[
variable explanation
f	- feature vector (type lVector)
g	- target/goal feature (type lVector)
n_N     - number of instances classified as negative in goal/target vector
n_P     - number of instances classified as positive in goal/target vector
]]
local function calc_benefit(
  f,
  g,
  n_N,
  n_P
  )
  -- START: Check parameters
  assert(type(n_N) == "Scalar")
  assert(type(n_P) == "Scalar")
  assert(n_N:to_num() >= 0)
  assert(n_P:to_num() >= 0)
  assert(type(g) == "lVector")
  assert(type(f) == "lVector")
  -- STOP: Check parameters

  --[[
  TODO: steps to follow in benefit calculation
  1. count intervals --> f', h0, h1 = Q.cntinterval(f, g)
  2. calculate benefit --> b = Q.wtbnfit(h0, h1, n_N, n_P)
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

  local n = (n_N + n_P):to_num()

  for i = 0, n-1 do
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
    local f_val_benefit = weighted_benefit(C[0], C[1], (n_N:to_num() - C[0]), (n_P:to_num() - C[1]))
    if f_val_benefit > benefit then
      benefit = f_val_benefit
      split_point = f_val
    end
  end
  return benefit, split_point
end

return calc_benefit
