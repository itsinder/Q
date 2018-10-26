local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'
local make_dt = require 'Q/ML/DT/lua/dt'['make_dt']
local check_dt = require 'Q/ML/DT/lua/dt'['check_dt']
local node_count = require 'Q/ML/DT/lua/dt'['node_count']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local predict = require 'Q/ML/DT/lua/evaluate_dt'['predict']
local print_dt = require 'Q/ML/DT/lua/evaluate_dt'['print_dt']
local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
local preprocess_dt = require 'Q/ML/DT/lua/evaluate_dt'['preprocess_dt']


local function run_dt(args)
  local meta_data_file	= assert(args.meta_data_file)
  local data_file	= args.data_file
  local goal		= assert(args.goal)
  local min_alpha	= assert(args.min_alpha)
  local max_alpha	= assert(args.max_alpha)
  local step_alpha	= assert(args.step_alpha)
  local train_csv   = args.train_csv
  local test_csv    = args.test_csv

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
  local T
  if data_file then
    T = Q.load_csv(data_file, dofile(meta_data_file), { is_hdr = args.is_hdr })
  end

  local alpha_gain = {}
  local alpha_cost = {}
  local alpha_accuracy = {}
  local alpha_precision = {}
  local alpha_recall = {}
  local alpha_f1_score = {}
  local alpha_c_d_score = {}
  local alpha_n_nodes = {}
  local alpha_mcc = {}
  local accuracy_std_deviation = {}
  local gain_std_deviation = {}
  local cost_std_deviation = {}
  local precision_std_deviation = {}
  local recall_std_deviation = {}
  local f1_score_std_deviation = {}
  local c_d_score_std_deviation = {}

  while min_alpha <= max_alpha do
    local gain = {}
    local cost = {}
    local accuracy = {}
    local precision = {}
    local recall = {}
    local f1_score = {}
    local c_d_score = {}
    local n_nodes = {}
    local mcc = {}
    local is_first = true
    for i = 1, iterations do
      local credit_val = 0
      local debit_val = 0

      -- break into a training set and a testing set
      local Train, Test
      if T then
        Train, Test = split_train_test(T, split_ratio, feature_of_interest, i*100)
      else
        assert(train_csv)
        assert(test_csv)
        Train = Q.load_csv(train_csv, dofile(meta_data_file))
        Test = Q.load_csv(test_csv, dofile(meta_data_file))
      end

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

      --============== Decision Tree Cost Evaluation ==============

      -- perform the preprocess activity
      -- initializes n_H1 and n_T1 to zero
      preprocess_dt(tree)

      -- predict for test samples
      for i = 1, n_test do
        local x = {}
        for k = 1, m_test do
          x[k] = test[k]:get_one(i-1)
        end
        local n_H, n_T = predict(tree, x)
        local decision
        if n_H > n_T then
          decision = 1 
        else
          decision = 0
        end
        predicted_values[i] = decision
        actual_values[i] = g_test:get_one(i-1):to_num()

        -- Calculate the credit and debit value
        n_H_prob = ( n_H / ( n_H + n_T ) ):to_num()
        n_T_prob = ( n_T / ( n_H + n_T ) ):to_num()
        if predicted_values[i] == 1 then
          if actual_values[i] == predicted_values[i] then
            credit_val = credit_val + n_H_prob
            debit_val = debit_val + n_T_prob
          else
            credit_val = credit_val + n_T_prob
            debit_val = debit_val + n_H_prob
          end
        else
          if actual_values[i] == predicted_values[i] then
            credit_val = credit_val + n_T_prob
            debit_val = debit_val + n_H_prob
          else
            credit_val = credit_val + n_H_prob
            debit_val = debit_val + n_T_prob
          end
        end
      end

      -- get node count
      local n_count = node_count(tree)
      n_nodes[#n_nodes+1] = n_count

      -- calculate credit-debit score
      c_d_score[#c_d_score+1] = ( credit_val - debit_val ) / n_test

      -- calculate dt cost
      local g, c = evaluate_dt(tree, g_train)
      gain[#gain+1] = g
      cost[#cost+1] = c

      -- print decision tree
      if is_first then
        local file_name = tostring(min_alpha) .. "_" .. tostring(i) .. "_graphviz.txt"
        local f = io.open(file_name, "a")
        f:write("digraph Tree {\n")
        f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
        f:write("edge [fontname=helvetica] ;\n")
        print_dt(tree, f, train_col_name)
        f:write("}\n")
        f:close()
        is_first = false
      end

      -- get classification_report
      local report = ml_utils.classification_report(actual_values, predicted_values)
      accuracy[#accuracy + 1] = report["accuracy_score"]
      precision[#precision + 1] = report["precision_score"]
      recall[#recall + 1] = report["recall_score"]
      f1_score[#f1_score + 1] = report["f1_score"]
      mcc[#mcc + 1] = report["mcc"]
    end
    alpha_gain[min_alpha] = ml_utils.average_score(gain)
    gain_std_deviation[min_alpha] = ml_utils.std_deviation_score(gain)

    alpha_cost[min_alpha] = ml_utils.average_score(cost)
    cost_std_deviation[min_alpha] = ml_utils.std_deviation_score(cost)

    alpha_accuracy[min_alpha] = ml_utils.average_score(accuracy)
    accuracy_std_deviation[min_alpha] = ml_utils.std_deviation_score(accuracy)

    alpha_precision[min_alpha] = ml_utils.average_score(precision)
    precision_std_deviation[min_alpha] = ml_utils.std_deviation_score(precision)

    alpha_recall[min_alpha] = ml_utils.average_score(recall)
    recall_std_deviation[min_alpha] = ml_utils.std_deviation_score(recall)

    alpha_f1_score[min_alpha] = ml_utils.average_score(f1_score)
    f1_score_std_deviation[min_alpha] = ml_utils.std_deviation_score(f1_score)

    alpha_c_d_score[min_alpha] = ml_utils.average_score(c_d_score)
    c_d_score_std_deviation[min_alpha] = ml_utils.std_deviation_score(c_d_score)

    alpha_n_nodes[min_alpha] = ml_utils.average_score(n_nodes)
    alpha_mcc[min_alpha] = ml_utils.average_score(mcc)

    min_alpha = min_alpha + step_alpha
  end

  local result = {}
  result['accuracy'] = alpha_accuracy
  result['gain'] = alpha_gain
  result['cost'] = alpha_cost
  result['accuracy_std_deviation'] = accuracy_std_deviation
  result['gain_std_deviation'] = gain_std_deviation
  result['cost_std_deviation'] = cost_std_deviation
  result['precision'] = alpha_precision
  result['recall'] = alpha_recall
  result['f1_score'] = alpha_f1_score
  result['precision_std_deviation'] = precision_std_deviation
  result['recall_std_deviation'] = recall_std_deviation
  result['f1_score_std_deviation'] = f1_score_std_deviation
  result['c_d_score'] = alpha_c_d_score
  result['c_d_score_std_deviation'] = c_d_score_std_deviation
  result['n_nodes'] = alpha_n_nodes
  result['mcc'] = alpha_mcc

  return result
end

return run_dt
