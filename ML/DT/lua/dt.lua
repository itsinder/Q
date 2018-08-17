local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/DT/lua/chk_params'

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
  if ( best_bf > alpha ) then 
    local x = Q.vsleq(T[best_k], best_sf)
    local T_L = {}
    local T_R = {}
    D.feature = best_k
    D.threshold = best_sp
    for k, f in pairs(T) do 
      T_L[k] = Q.where(T[k], x)
      T_R[k] = Q.where(T[k], Q.vnot(x))
    end
    D.left  = make_dt(T_L, g_L, alpha)
    D.right = make_dt(T_R, g_R, alpha)
  else
    D.n_N = n_N
    D.n_P = n_P
  end
  return D
end

return make_dt
