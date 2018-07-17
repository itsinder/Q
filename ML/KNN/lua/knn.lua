local function knn(
  T, -- table of m Vectors of length n
  g, -- Vector of length n
  x, -- Lua table of m Scalars
  k -- number of neighbors we care about
  )
  local n = g:length()
  local m = #T
  local d = {}
  local d[0] = Q.const({val = 0, qtype = "F4", len = n})
  for i = 1, m do -- for each attribute
    d[i] = Q.vvadd(d[i-1], Q.sqr(Q.vssub(T[i], x[i])))
  end
  return Q.mink(d[m], g, k)
end
