local Q = require 'Q'
local classify = require 'Q/ML/knn/lua/classify'
local Scalar = require 'libsclr'
local tests = {}

tests.t1 = function()
  local n = 2
  local m = 4
  local g_vec        -- it's size will be n
  local x            -- input sample of length m, it is not vector
  local alpha        -- it's length is m, it is not vector
  
  local train_vec

  local T = {}
  for i = 1, m do
    T[i] = Q.mk_col({2, 4}, "F4")
  end

  g_vec = Q.mk_col({0, 1}, "I4")

  local x_val = Scalar.new(3, "F4")
  x = {x_val, x_val, x_val, x_val}

  local alpha_val = Scalar.new(1, "F4")
  alpha = {alpha_val, alpha_val, alpha_val, alpha_val}

  local result = classify(T, g_vec, x, alpha)
  assert(type(result) == "lVector")
  Q.print_csv(result)
end

return tests
