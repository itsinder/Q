local Q = require 'Q'

local function knn(
  T, -- table of m Vectors of length n
  g, -- Vector of length n
  x, -- Lua table of m Scalars
  k -- number of neighbors we care about
  )
  local n = g:length()
  local m = #T
  local d = {}
  d[0] = Q.const({val = 0, qtype = "F4", len = n})
  for i = 1, m do -- for each attribute
    -- d[i] = Q.vvadd(d[i-1], Q.sqr(Q.vssub(T[i], x[i])))
    d[0] = Q.vvadd(d[0], Q.sqr(Q.vssub(T[i], x[i])))
  end
  -- commented the above line as other table values i.e vectors are not of any use
  return Q.mink_reducer(d[0], g, k)
end

return knn
