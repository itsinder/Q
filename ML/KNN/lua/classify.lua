local Q = require 'Q'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/KNN/lua/chk_params'

local function classify(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
<<<<<<< HEAD:ML/knn/lua/classify.lua
  x, -- table of m Scalars 
=======
  x, -- table of m Scalars
>>>>>>> dev:ML/KNN/lua/classify.lua
  exponent, -- Scalar
  alpha, -- table of m Scalars (scale for different attributes)
  cnts -- lVector of length m (optional)
  )
  local sone = Scalar.new(1, "F4")
  --==============================================
<<<<<<< HEAD:ML/knn/lua/classify.lua
  local nT, n, ng = chk_params(T, g, x, alpha)
  dk = {}
  for i = 1, nT do 
    dk[i] = Q.vsmax(Q.abs(Q.vsmul(Q.pow(Q.vssub(T[i], x[i]), exponent), alpha[i])), sone)
  end
  local d = Q.const({ val = sone, qtype = "F4", len = n})
  for i = 1, nx do 
    d = Q.vvsum(dk[i], d):eval()
=======
  local nT, n, ng = chk_params(T, g, x, exponent, alpha)
  dk = {}
  local i = 1
  for key, val in pairs(T) do
    dk[i] = Q.vsmax(Q.abs(Q.vsmul(Q.pow(Q.vssub(val, x[i]), exponent), alpha[i])))
    i = i + 1
  end
  local d = Q.const({ val = sone, qtype = "F4", len = n})
  for i = 1, nT do 
    d = Q.vvadd(dk[i], d):eval()
>>>>>>> dev:ML/KNN/lua/classify.lua
  end
  d = Q.reciprocal(d):eval()
  -- Now, we need to sum d grouped by value of goal attribute
  local rslt = Q.sumby(d, g, ng)
  -- Scale by original population, calculate cnts if not given
  local l_cnts
  if ( not cnts ) then 
    local vone = Q.const({ val = sone, qtype = "F4", len = n})
    l_cnts = Q.sumby(vone, g, ng)
  else
    l_cnts = cnts
  end
  rslt = Q.vvdiv(rslt, l_cnts)
  --=============================
  return rslt 
end

return classify
