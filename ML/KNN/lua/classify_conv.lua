local Q = require 'Q'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/KNN/lua/chk_params'

local function classify(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  x, -- table of m Scalars
  exponent, -- Scalar
  alpha, -- table of m Scalars (scale for different attributes)
  cnts -- lVector of length m (optional)
  )
  local sone = Scalar.new(1, "F4")
  local szero = Scalar.new(0, "F4")
  --==============================================
  local nT, n, ng = chk_params(T, g, x, exponent, alpha)
  local distance = Q.const({val = szero, qtype = "F4", len = n})
  dk = {}
  local i = 1

  for key, val in pairs(T) do
    dk[i] = Q.vsmul(Q.pow(Q.vssub(val, x[i]), exponent), alpha[i])
    i = i + 1
  end

  for i = 1, nT do
    distance = Q.vvadd(dk[i], distance)
  end

  distance = Q.sqrt(distance)

  -- Now, we need to sum d grouped by value of goal attribute
  local rslt = Q.sumby(distance, g, ng)

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
