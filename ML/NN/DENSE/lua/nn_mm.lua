local function nn_mm(I, W, b)


local function step_forward_mm(
  I, -- input table
  W, 
  b
  )
  
  local m = chk1(I) -- number of neurons in input layer
  local n = chk1(W) -- number of neurons in output layer
  assert(b and (type(b) == "lVector"))
  --==============================
  O = nn_mm(I, W, b)
  return O

end

return add_layer
