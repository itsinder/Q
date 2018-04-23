local Q = require 'Q'
local classify = require 'Q/ML/knn/lua/classify'
local utils = require 'Q/UTILS/lua/utils'
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

tests.t2 = function()
  -- TODO: Add load code for iris_flower data
  -- Load the iris flower data
  local saved_file = os.getenv("Q_METADATA_DIR") .. "/iris_flower.saved"
  dofile(saved_file)

  local g_vec = T['flower_type']

  -- Remove 'flower_type' from table
  T['flower_type'] = nil

  -- predict_input {5.5, 2.3, 4.0, 1.3}, prediction result = 1 i.e of type "Iris-versicolor" 
  local x = {Scalar.new(5.5, "F4"), Scalar.new(2.3, "F4"), Scalar.new(4.0, "F4"), Scalar.new(1.3, "F4")}

  local alpha_val = Scalar.new(1, "F4")
  alpha = {alpha_val, alpha_val, alpha_val, alpha_val}

  local result = classify(T, g_vec, x, alpha)
  assert(type(result) == "lVector")
  Q.print_csv(result)
  print("completed t2 successfully")
end

tests.t3 = function()
  -- TODO: add load code for room_occupancy data
  -- Load the iris flower data
  local saved_file = os.getenv("Q_METADATA_DIR") .. "/room_occupancy.saved"
  dofile(saved_file)

  local g_vec = T['occupy_status']

  -- Remove 'flower_type' from table
  T['occupy_status'] = nil

  -- predict_input {1.643221, 0.281781, -0.613726, 0.004625, 0.797606}, prediction result = 0
  local x = {Scalar.new(1.643221, "F4"), Scalar.new(0.281781, "F4"), Scalar.new(-0.613726, "F4"), Scalar.new(0.004625, "F4"), Scalar.new(0.797606, "F4")}

  local alpha_val = Scalar.new(1, "F4")
  alpha = {alpha_val, alpha_val, alpha_val, alpha_val, alpha_val}

  local result = classify(T, g_vec, x, alpha)
  assert(type(result) == "lVector")
  Q.print_csv(result)
  print("completed t3 successfully")
end

return tests
