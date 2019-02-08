local Q = require 'Q'
local chk1 = require 'Q/ML/NN/DENSE/lua/chk1'

local function add_layer(
  X, -- input table
  n, -- number of neurons in output layer
  init_params -- details on initializations
  )
  local m = chk1(X) -- m = number of neurons in input layer

  assert(n and (type(n) == "number") and (n > 0) )
  local W = {}
  -- TODO Deal with init params, hard code for now
  local qtype = "F4"
  for i = 1, n do
    W[i] = Q.rand({ qtype = qtype, len = m})
  end
  local b = Q.rand({ qtype = qtype, len = m})
  return W, b
end

return add_layer
