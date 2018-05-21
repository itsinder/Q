local Q = require 'Q'
local Scalar = require 'libsclr'
local chk_params = require 'Q/ML/KNN/lua/chk_params'

local function voting(
  T, -- table of m lVectors of length n
  g, -- lVector of length n
  x, -- table of m Scalars, input
  args
  )

  -- It is a Scalar
  local exponent = Scalar.new(2, "F4")
  if args.exponent then
    exponent = args.exponent
  end

  -- table of m Scalars (scale for different attributes)
  local alpha = args.alpha

  -- voting algo (string)
  local voting_algo = "one_over_one_plus"
  if args.voting_algo then
    voting_algo = args.voting_algo
    -- TODO: below assert needs to be in chk_params
    assert(type(voting_algo) == "string")
  end
  --==============================================
  local m, n, ng = chk_params(T, g, x, exponent, alpha)
  dk = {}
  local i = 1
  for key, vec in pairs(T) do
    dk[i] = Q.vsmul(Q.pow(Q.vssub(vec, x[i]), 2), alpha[i])
    i = i + 1
  end
  local d = Q.const({ val = 0, qtype = "F4", len = n})
  for i = 1, m do 
    d = Q.vvadd(dk[i], d)
  end
  if ( voting_algo == "one_over_one_plus" ) then 
    if ( exponent ~= 1 ) then 
      d = Q.pow(d, exponent)
    end 
    d = Q.reciprocal(Q.vsadd(d, Scalar.new(1, "F4")))
  elseif ( voting_algo == "exp_minus" ) then 
    if ( exponent ~= 1 ) then 
      d = Q.vsmul(d, exponent)
    end
    d = Q.exp(Q.vsmul(d, Scalar.new(-1, "F4")))
  else
    assert(nil, "unknown voting algo" .. voting_algo)
  end
  -- Now, we need to sum d grouped by value of goal attribute
  local rslt = Q.sumby(d, g, ng)
  --=============================
  return rslt 
end
return voting
