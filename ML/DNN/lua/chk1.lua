local function chk1(X)
  assert(type(X) == "table")
  local m = #I -- number of neurons in input layer
  assert(m > 0)
  for k , v in pairs(X) do 
    assert(type(X[k]) == "lVector")
  end
  return m
end
return chk1
