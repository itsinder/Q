local function knn(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  x, -- table of m Scalars
  k -- number of neighbors we care about
  )
  local n = g:length()
  local d = Q.const({val = 0, qtype = "F4", len = n})
  for i, vec in ipairs(T) do
    d = Q.add(d, Q.sqr(Q.vssub(vec, x[i])))
  end
  return Q.mink(d, g, k)
end
