local Q = require 'Q'
local chk_params = require 'Q/ML/DT/lua/chk_params'

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
