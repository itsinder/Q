local Q = require 'Q'
local function referer_count(r) -- r = referer
  assert(type(r) == "lVector")
  local s = Q.dup(r)
  Q.sort(s, "ascending")
  z = Q.cum_count(s)
  y = Q.is_prev("geq", z, { default_val = 1 })

  t1 = Q.where(z,s)
  local nt2 = Q.max(t1):eval() + 1
  t2 = Q.numby(t1, nt2)
  idx = Q.seq( { start = 0, by = 1, qtype = "I4", len = nt2})
  Q.print_csv({idx, t2})
end
return referer_count
