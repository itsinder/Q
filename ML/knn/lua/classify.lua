local Q = require 'Q'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/knn/lua/chk_params'

local function classify(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  x, -- table of m Scalars 
  alpha, -- table of m Scalars (scale for different attributes)
  cnts -- lVector of length m (optional)
  )
  local nT, n, ng = chk_params(T, g, x, alpha)
  print(nT, n, ng)
  dk = {}
  for i = 1, nT do 
    dk[i] = Q.vsmul(Q.pow(Q.vssub(T[i], x[i]), 2), alpha[i])
  end
  local one = Scalar.new(1, "F4")
  local d = Q.const({ val = one, qtype = "F4", len = n})
  for i = 1, nT do 
    d = Q.vvadd(dk[i], d):eval()
  end
  d = Q.reciprocal(d):eval()
  -- Now, we need to sum d grouped by value of goal attribute
  local rslt = Q.sumby(d, g, ng)
  -- Scale by original population, calculate cnts if not given
  local l_cnts
  if ( not cnts ) then 
    local vone = Q.const({ val = one, qtype = "F4", len = n})
    l_cnts = Q.sumby(vone, g, ng)
  else
    l_cnts = cnts
  end
  rslt = Q.vvdiv(rslt, l_cnts)
  --=============================
  return rslt 
end

return classify
