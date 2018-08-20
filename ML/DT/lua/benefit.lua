local Q = require 'Q'

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
  Q.sort2(f, g)

  -- counters for goal values
  local C = {}
  C[0] = 0
  C[1] = 0

  for i = 0, (n_N + n_P) do
    local f_val = f:get_one(i)
    local g_val = g:get_one(i)
    C[g_val] = C[g_val] + 1
    i = i + 1
    while i < (n_N + n_P)  do
      local fi_val = f:get_one(i)
      local gi_val = g:get_one(i)
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

