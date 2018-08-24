local Q = require 'Q'

--[[

variable explanation
n_N     - number of instances classified as negative in goal/target vector
n_P     - number of instances classified as positive in goal/target vector
n_N_L	- number of negatives on left
n_P_L	- number of positives on left

]]

local function weighted_benefit(
  n_N_L,
  n_P_L,
  n_N,
  n_P
  )
  -- TODO how to get values of x and y
  local x = 1
  local y = 1
  local n_N_R = n_N - n_N_L
  local n_P_R = n_P - n_P_L
  local n_L = n_N_L + n_P_L
  local n_R = n_N_R + n_P_R
  local wt_benefit = ( n_L / ( n_N + n_P ) ) * x + ( n_R / ( n_N + n_P ) ) * y
  return wt_benefit
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
  assert(n_N >= 0)
  assert(n_P >= 0)
  assert(type(g) == "lVector")
  assert(type(f) == "lVector")
  -- STOP: Check parameters

  local benefit = -math.huge
  local split_point = nil

  -- sort f in ascending order and g in drag along
  -- before sort, clone the vectors
  local f_clone = f:clone()
  local g_clone = g:clone()
  Q.sort2(f_clone, g_clone)

  -- counters for goal values
  local C = {}
  C[0] = 0
  C[1] = 0

  for i = 0, (n_N + n_P) do
    local f_val = f_clone:get_one(i)
    local g_val = g_clone:get_one(i)
    C[g_val] = C[g_val] + 1
    i = i + 1
    while i < (n_N + n_P)  do
      local fi_val = f_clone:get_one(i)
      local gi_val = g_clone:get_one(i)
      if fi_val ~= f_val then
        break
      end
      C[gi_val] = C[gi_val] + 1
      i = i + 1
    end
    local f_val_benefit = weighted_benefit(C[0], C[1], n_N, n_P)
    if f_val_benefit > benefit then
      benefit = f_val_benefit
      split_point = f_val
    end
  end
  return benefit, split_point
end

return calc_benefit
