local Q = require 'Q'
local Scalar = require 'libsclr'
local classify = require 'Q/ML/KNN/lua/classify'
local utils = require 'Q/UTILS/lua/utils'

local get_train_test_split = function(split_ratio, global_T, total_length)
  local Train = {}
  local Test = {}
  local random_vec = Q.rand({lb = 0, ub = 1, qtype = "F4", len = total_length}):eval()
  local random_vec_bool = Q.vsleq(random_vec, split_ratio):eval()

  for i, v in pairs(global_T) do
    Train[i] = Q.where(v, random_vec_bool):eval()
    Test[i] = Q.where(v, Q.vsnot(random_vec_bool)):eval()
  end
  
  return Train, Test
end

local get_accuracy = function(expected_val, predicted_val)
  assert(type(expected_val) == "table")
  assert(type(predicted_val) == "table")
  assert(#expected_val == #predicted_val)
  local correct = 0
  for i = 1, #expected_val do
    if expected_val[i] == predicted_val[i] then
      correct = correct + 1
    end
  end
  return (correct/#expected_val)*100
end

local run_knn = function(iterations, splt_ratio, alpha, exp, goal_column_index)
  -- It's assumed that data is already loaded into global_T variable
  -- global_T will be a table having vectors as it's elements

  local accuracy = {}

  assert(iterations > 0)
  assert(type(alpha) == "table")

  local exponent = Scalar.new(2, "F4")
  if exp then
    assert(type(exp) == "Scalar")
    exponent = exp
  end

  local split_ratio = 0.8
  if splt_ratio then
    assert(type(splt_ratio) == "number")
    assert(splt_ratio < 1 and splt_ratio > 0)
    split_ratio = splt_ratio
  end
  
  for itr = 1, iterations do
    local Train, Test = get_train_test_split(split_ratio, T, T[goal_column_index]:length())
    --[[
    print(T[goal_column_index]:length())
    print("#############################")
    print("TRAIN")
    for i, v in pairs(Train) do
      print(i, v:length())
    end
    print("#############################")
    print("TEST")
    for i, v in pairs(Test) do
      print(i, v:length())
    end
    ]]
    local g_vec_train = Train[goal_column_index]
    Train[goal_column_index] = nil
    local g_vec_test = Test[goal_column_index]
    Test[goal_column_index] = nil

    -- Prepare test table
    local test_sample_count = g_vec_test:length()
    local val, nn_val
    local X = {}
    local expected_predict_value = {}
    local actual_predict_value = {}

    for len = 1, test_sample_count do
      local x = {}
      for i, v in pairs(Test) do
        val, nn_val = v:get_one(len-1)
        x[#x+1] = Scalar.new(val:to_num(), "F4")
      end
      expected_predict_value[len] = g_vec_test:get_one(len-1):to_num()
      X[len] = x
    end

    local result
    local max
    local index
    for i = 1, test_sample_count do
      -- predict for inputs
      result = classify(Train, g_vec_train, X[i], exponent, alpha)
      assert(type(result) == "lVector")
      max = Q.max(result):eval():to_num()
      index = utils.get_index(result, max)
      actual_predict_value[i] = index
    end
    local acr = get_accuracy(expected_predict_value, actual_predict_value)
    -- print("Accuracy: " .. tostring(acr))
    accuracy[#accuracy + 1] = acr
  end
  return accuracy
end

return run_knn
