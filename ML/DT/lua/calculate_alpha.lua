local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'
local make_dt = require 'Q/ML/DT/lua/dt'['make_dt']
local check_dt = require 'Q/ML/DT/lua/dt'['check_dt']
local print_dt = require 'Q/ML/DT/lua/dt'['print_dt']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local predict = require 'Q/ML/DT/lua/dt_cost_evaluation'['predict']
local evaluate_dt_cost = require 'Q/ML/DT/lua/dt_cost_evaluation'['evaluate_dt_cost']
local cost_calc_preprocess = require 'Q/ML/DT/lua/dt_cost_evaluation'['cost_calc_preprocess']


local function run_dt(args)
  local meta_data_file	= assert(args.meta_data_file)
  local data_file	= assert(args.data_file)
  local goal		= assert(args.goal)
  local min_alpha	= assert(args.min_alpha)
  local max_alpha	= assert(args.max_alpha)
  local step_alpha	= assert(args.step_alpha)

  local iterations = 1
  if args.iterations then
    assert(type(args.iterations == "number"))
    iterations = args.iterations
  end
  assert(iterations > 0)

  local split_ratio = 0.7
  if args.split_ratio then
    assert(type(args.split_ratio) == "number")
    assert(args.split_ratio < 1 and args.split_ratio > 0)
    split_ratio = args.split_ratio
  end
  assert(split_ratio < 1 and split_ratio > 0)

  local feature_of_interest
  if args.feature_of_interest then
    assert(type(args.feature_of_interest) == "table")
    feature_of_interest = args.feature_of_interest
  end

  -- load the data
  local T = Q.load_csv(data_file, dofile(meta_data_file))

  local accuracy = {}
  local alpha_cost_val = {}

  while min_alpha <= max_alpha do
    local cost = 0
    for i = 1, iterations do
      -- break into a training set and a testing set
      local Train, Test = split_train_test(T, split_ratio, feature_of_interest)
      local train, g_train, m_train, n_train, train_col_name = extract_goal(Train, goal)
      local test,  g_test,  m_test,  n_test, test_col_name  = extract_goal(Test,  goal)

      -- Current implementation assumes 2 values of goal as 0, 1
      local min_g, _ = Q.min(g_train):eval()
      assert(min_g:to_num() == 0)
      local max_g, _ = Q.max(g_train):eval()
      assert(max_g:to_num() == 1)

      local predicted_values = {}
      local actual_values = {}

      -- prepare decision tree
      local tree = make_dt(train, g_train, Scalar.new(min_alpha, "F4"))
      assert(tree)

      -- verify the decision tree
      check_dt(tree)

      -- print decision tree
      --[[
      local f = io.open("graphviz.txt", "a")
      f:write("digraph {\n")
      print_dt(tree, f, train_col_name)
      f:write("}\n")
      f:close()
      ]]

      --============== Decision Tree Cost Evaluation ==============

      -- perform the preprocess activity
      cost_calc_preprocess(tree)

      -- predict for test samples
      for i = 1, n_test do
        local x = {}
        for k = 1, m_test do
          x[k] = test[k]:get_one(i-1)
        end
        local n_P, n_N = predict(tree, x)
        local decision
        if n_P > n_N then
          decision = 1 
        else
          decision = 0
        end
        predicted_values[#predicted_values+1] = decision
        actual_values[#actual_values+1] = g_test:get_one(i-1):to_num()
      end

      -- calculate dt cost
      cost = cost + evaluate_dt_cost(tree, g_train)

      local acr = ml_utils.calc_accuracy(actual_values, predicted_values)
      -- print("Accuracy: " .. tostring(acr))
      accuracy[#accuracy + 1] = acr
    end
    alpha_cost_val[min_alpha] = ( cost / iterations )
    min_alpha = min_alpha + step_alpha
  end
  return ml_utils.calc_average(accuracy), accuracy, alpha_cost_val
end

return run_dt
