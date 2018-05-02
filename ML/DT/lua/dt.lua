local Q = require 'Q'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/DT/lua/chk_params'


local function benefit(
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
  assert(type(g) == "Vector")
  -- STOP: Check parameters

return benefit, split_point
end

local function make_dt(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  alpha -- Scalar, minimum benefit
  )
  local m, n, ng = chk_params(T, g)
  
  local vone = Q.const({ val = sone, qtype = "I4", len = n})
  -- TODO local cnts = Q.numby(g, ng)
  local n_N = cnts:get1(0)
  local n_P = cnts:get1(1)
  local best_bf, best_sp, best_k
  for k, f in pairs(T) do 
    local bf, sf = benefit(f, g, n_N, n_P)
    if ( best_bf == nil ) or ( bf > best_bf ) then
      best_bf = bf
      best_sp = sp
      best_k = k
    end
  end
  if ( best_bf > alpha ) then 
    local x = Q.vsleq(T, best_sp)
    local T_L = {}
    local T_R = {}
    T.feature = best_k
    T.threshold = best_sp
    for k, f in pairs(T) do 
      T_L[k] = Q.where(T[k], x)
      T_R[k] = Q.where(T[k], Q.vnot(x))
    end
    T.left  = make_dt(T_L, g_L, alpha)
    T.right = make_dt(T_R, g_R, alpha)
  end
  return T
end

return make_dt
