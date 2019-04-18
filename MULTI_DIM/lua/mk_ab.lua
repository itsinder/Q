local Q = require 'Q'

local function mk_ab(len, p)
  assert( (type(len) == "number") and ( len > 0 ) )
  assert( (type(p) == "number") and ( p > 0 ) and ( p < 1 ) )
  local a = Q.rand( { probability = p, qtype = "B1", len = len })
  local b = Q.rand( { probability = p, qtype = "B1", len = len })
  local sum_a = Q.sum(a)
  local sum_b = Q.sum(b)
  print(sum_a:eval(), sum_b:eval())
end
-- mk_ab(1048575, 0.5)
return mk_ab
