local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'
local make_dt = require 'Q/ML/DT/lua/dt'['make_dt']
local check_dt = require 'Q/ML/DT/lua/dt'['check_dt']
local node_count = require 'Q/ML/DT/lua/dt'['node_count']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local predict = require 'Q/ML/DT/lua/dt'['predict']
local print_dt = require 'Q/ML/DT/lua/dt'['print_dt']
local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
local preprocess_dt = require 'Q/ML/DT/lua/dt'['preprocess_dt']

local function init_metrics()
  local metrics = {}
  metrics.accuracy  = {}
  metrics.precision = {}
  metrics.recall    = {}
  metrics.f1_score  = {}
  metrics.mcc       = {}
  metrics.payout    = {}
  return metrics
end
local function  calc_avg_metrics(metrics)
  local out_metrics = {}
  -- calculate avg and standard deviation for each metric 
  for k, v in pairs(metrics) do 
    out_metrics[k] = {}
    local stats = {}
    out_metrics[k].avg = ml_utils.average_score(v)
    out_metrics[k].sd  = ml_utils.std_deviation_score(v)
  end
  return out_metrics
end

local function run_dt(args)
  local meta_data_file	= assert(args.meta_data_file)
  local data_file	= args.data_file 
  local goal		= assert(args.goal)
  if ( not data_file ) then 
    assert(args.train_csv)
    assert(args.test_csv)
  else
    assert(args.train_csv == nil)
    assert(args.test_csv == nil)
  end

  local alpha, min_alpha, max_alpha, step_alpha
  if args.alpha then
    alpha = args.alpha
    if type(alpha) ~= "Scalar" then
      alpha = Scalar.new(alpha, "F4")
    end
    min_alpha = alpha
    max_alpha = alpha
    step_alpha = Scalar.new(1.0, "F4")
  else
    min_alpha	= assert(args.min_alpha)
    max_alpha	= assert(args.max_alpha)
    step_alpha	= assert(args.step_alpha)
    if type(min_alpha) ~= "Scalar" then
      min_alpha = Scalar.new(min_alpha, "F4")
    end
    if type(max_alpha) ~= "Scalar" then
      max_alpha = Scalar.new(max_alpha, "F4")
    end
    if type(step_alpha) ~= "Scalar" then
      step_alpha = Scalar.new(step_alpha, "F4")
    end
  end

  local iterations = 1
  if args.iterations then
    assert(type(args.iterations == "number"))
    iterations = args.iterations
  end
  assert(iterations > 0)

  local split_ratio = 0.7
  if args.split_ratio then
    split_ratio = args.split_ratio
  end
  assert(type(split_ratio) == "number")
  assert(split_ratio < 1 and split_ratio > 0)

  local feature_of_interest
  if args.feature_of_interest then
    assert(type(args.feature_of_interest) == "table")
    feature_of_interest = args.feature_of_interest
  end

  -- load the data
  local T
  if data_file then
    T = Q.load_csv(data_file, dofile(meta_data_file), { is_hdr = args.is_hdr })
  end

  -- start iterating over range of alpha values
  local results = {}
  while min_alpha <= max_alpha do
    local   is_first = true
    -- convert scalar to number for alpha value, avoid extra decimals
    local cur_alpha = utils.round_num(min_alpha:to_num(), 2)

    local metrics = init_metrics ()
    for iter = 1, iterations do
      -- break into a training set and a testing set
      local Train, Test
      if T then
        local seed = iter * 100
        Train, Test = split_train_test(T, split_ratio, 
          feature_of_interest, seed)
      else
        assert(args.train_csv)
        assert(args.test_csv)
        Train = Q.load_csv(args.train_csv, dofile(meta_data_file), 
          { is_hdr = args.is_hdr })
        Test = Q.load_csv(args.test_csv, dofile(meta_data_file), 
          { is_hdr = args.is_hdr })
      end

      local train, g_train, m_train, n_train, train_col_name = 
        extract_goal(Train, goal)
      local test,  g_test,  m_test,  n_test, test_col_name  = 
        extract_goal(Test,  goal)
      assert(m_train == m_test)

      -- Current implementation assumes 2 values of goal as 0, 1
      local min_g, _ = Q.min(g_train):eval()
      assert(min_g:to_num() == 0)
      local max_g, _ = Q.max(g_train):eval()
      assert(max_g:to_num() == 1)

      local predicted_values = {}
      local actual_values    = {}

      -- prepare decision tree
      local tree = assert(make_dt(train, g_train, min_alpha, 
        args.min_to_split, args.wt_prior))
      check_dt(tree)
      --============== Decision Tree Cost Evaluation ==============
      preprocess_dt(tree) -- initializes n_H1 and n_T1 to zero at leaves
      -- predict for test samples
      local TAILS = 0
      local HEADS = 1
      for i = 1, n_test do
        local x = {}
        for k = 1, m_test do
          x[k] = test[k]:get_one(i-1):to_num()
        end
        local n_H, n_T = predict(tree, x)
        local decision
        if n_H > n_T then
          decision = HEADS
        else
          decision = TAILS
        end
        predicted_values[i] = decision
        actual_values[i]    = g_test:get_one(i-1):to_num()
      end
      metrics.payout[iter] = evaluate_dt(tree) -- calculate payout
      -- get classification_report
      local report = ml_utils.classification_report(
        actual_values, predicted_values)
      metrics.accuracy[iter]   = report['accuracy']
      metrics.precision[iter]  = report['precision']
      metrics.recall[iter]     = report['recall']
      metrics.f1_score[iter]   = report['f1_score']
      metrics.mcc[iter]        = report['mcc']
    end
    local avg_metrics = calc_avg_metrics(metrics)
    results[alpha] = avg_metrics
    min_alpha = min_alpha + step_alpha
  end
  return results
end

return run_dt
--[[
      -- print decision tree
      if is_first then
        local file_name = tostring(cur_alpha) .. "_" .. tostring(i) .. "_graphviz.txt"
        local f = io.open(file_name, "w")
        f:write("digraph Tree {\n")
        f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
        f:write("edge [fontname=helvetica] ;\n")
        print_dt(tree, f, train_col_name)
        f:write("}\n")
        f:close()
        is_first = false
      end
--]]
