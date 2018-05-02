local Q      = require 'Q'
local Scalar = require 'libsclr'
local function get_alpha(x, exponent)
  assert(x)
  assert(type(x) == "lVector")
  assert(exponent)
  if ( type(exponent) == "Scalar" ) then
    exponent = exponent:to_num()
  else
    assert(type(exponent) == "number" ) 
  end

  local n = x:length()
  assert(n > 0) -- means vector must be materialized
  local k = Scalar.new(10, "I8") -- calculate properly
  local y = Q.clone(x)
  local z = Q.sort(y, "asc")
  local maxminval = z:get_one(k-1)
  local minmaxval = z:get_one(n-k)
  --[[
  local low  = Q.topk(x, k, "min")
  local high = Q.topk(x, k, "max")
  local maxminval = low:get_one(k-1)
  local minmaxval = high:get_one(0)
  --]]
  local alpha = minmaxval - maxminval 
  local alpha = math.abs(math.pow(alpha:to_num(), exponent))
end
return get_alpha
