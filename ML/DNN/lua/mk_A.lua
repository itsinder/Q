local Q = require 'Q'
local chk1 = require 'Q/ML/NN/DENSE/lua/chk1'

local function step_forward_mm(
  I, -- input table
  W, 
  b
  )
  --==============================
  local m = chk1(I) -- number of neurons in input layer
  local n = chk1(W) -- number of neurons in output layer
  assert(b and (type(b) == "lVector"))
  --==============================
  O = 
  return O

end

return add_layer
