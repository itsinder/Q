local Q = require 'Q'

local function prediction_from_votes(
  V,
  num_g
  )
  assert(type(V) == "table")
  local ng = 0
  local n 
  local lV = {}
  for k, v in pairs(V) do 
    assert(type(v) == "lVector")
    lV[ng] = v
    ng = ng + 1
    if ( not n ) then 
      n = v:length()
    else
      assert(n == v:length())
    end
  end
  assert(ng == 2) -- TODO Not ready for others
  y = Q.const({ val = 0, len = n, qtype = "I4"})
  z = Q.const({ val = 1, len = n, qtype = "I4"})
  if ( num_g ) then 
    assert(type(num_g) == "table")
    lV[0] = Q.vsdiv(lV[0], num_g[0]);
    lV[1] = Q.vsdiv(lV[1], num_g[1]);
  end
  x = Q.vvgeq(lV[0], lV[1])
  w = Q.ifxthenyelsez(x, y, z)
  return w
end
return prediction_from_votes
