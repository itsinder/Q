local Q = require 'Q'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")

local tests = {}

-- Dataset: b_cancer/cancer_data_test.csv
tests.t1 = function()
  local sklearn_to_q_dt = require "Q/ML/DT/lua/sklearn_to_q_dt"
  local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
  local predict = require 'Q/ML/DT/lua/dt'['predict']
  local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
  local print_g_dt      = require 'Q/ML/DT/lua/graphviz_to_q_dt'['print_dt']
  local node_count = require 'Q/ML/DT/lua/dt'['node_count']
  local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_1'

  local features_list = { "id", "diagnosis", "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean","compactness_mean", "concavity_mean", "concave points_mean", "symmetry_mean", "fractal_dimension_mean", "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concave points_se", "symmetry_se", "fractal_dimension_se", "radius_worst","texture_worst", "perimeter_worst", "area_worst", "smoothness_worst","compactness_worst", "concavity_worst", "concave points_worst", "symmetry_worst", "fractal_dimension_worst" }
  local goal_feature = "diagnosis"
  local D = sklearn_to_q_dt(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_b_cancer_accuracy.txt", features_list, goal_feature)
  -- printing the q decision tree structure in a file
  local fp = io.open(Q_SRC_ROOT .. "/ML/DT/test/t1_imported_graphviz_dt.txt", "w")
  fp:write("digraph Tree {\n")
  fp:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  fp:write("edge [fontname=helvetica] ;\n")

  print_g_dt(D, fp)
  fp:write("}\n")
  fp:close()

  -- calling the Q decision tree with same training samples as passed to sklearn
  local args = {}
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data_train.csv"
  args.test_csv  = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data_test.csv"
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  args.is_hdr = true
  args.goal = goal_feature
  args.tree = D

  local gain = {}
  local cost = {}
  local precision = {}
  local recall = {}
  local f1_score = {}
  local c_d_score = {}
  local n_nodes = {}
  local mcc = {}

  local credit_val = 0
  local debit_val = 0
      
  local Train, Test
  assert(args.test_csv)
  assert(args.meta_data_file)
  Train = Q.load_csv(args.train_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})
  Test  = Q.load_csv(args.test_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})
  local abc1, g_train, abc2, abc3, abc3 = extract_goal(Train, args.goal)
  local test,  g_test,  m_test,  n_test, test_col_name  = extract_goal(Test,  args.goal)
  local predicted_values = {}
  local actual_values = {}
  local accuracy = {}
  -- predict for test samples
  for i = 1, n_test do
    local x = {}
    for k = 1, m_test do
      x[k] = test[k]:get_one(i-1)
    end
    local n_H, n_T = predict(D, x)
    --print(type(n_H), type(n_T))
    local decision
    if n_H > n_T then
      decision = 1 
    else
      decision = 0
    end
    predicted_values[i] = decision
    actual_values[i] = g_test:get_one(i-1):to_num()
    --print(( n_H / ( n_H + n_T ) ))
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
  local n_count = node_count(D)
  n_nodes[#n_nodes+1] = n_count

  -- calculate credit-debit score
  c_d_score[#c_d_score+1] = ( credit_val - debit_val ) / n_test

  -- calculate dt cost
  local g, c = evaluate_dt(D, g_train)
  gain[#gain+1] = g
  cost[#cost+1] = c

  -- get classification_report
  local report = ml_utils.classification_report(actual_values, predicted_values)
  accuracy[#accuracy + 1] = report["accuracy_score"]
  precision[#precision + 1] = report["precision_score"]
  recall[#recall + 1] = report["recall_score"]
  f1_score[#f1_score + 1] = report["f1_score"]
  mcc[#mcc + 1] = report["mcc"]

  local result = {}
  result['accuracy'] = ml_utils.average_score(accuracy)
  result['gain'] = ml_utils.average_score(gain)
  result['cost'] = ml_utils.average_score(cost)
  result['accuracy_std_deviation'] = ml_utils.std_deviation_score(accuracy)
  result['gain_std_deviation'] = ml_utils.std_deviation_score(gain)
  result['cost_std_deviation'] = ml_utils.std_deviation_score(cost)
  result['precision'] = ml_utils.average_score(precision)
  result['recall'] = ml_utils.average_score(recall)
  result['f1_score'] = ml_utils.average_score(f1_score)
  result['precision_std_deviation'] = ml_utils.std_deviation_score(precision)
  result['recall_std_deviation'] = ml_utils.std_deviation_score(recall)
  result['f1_score_std_deviation'] = ml_utils.std_deviation_score(f1_score)
  result['c_d_score'] = ml_utils.average_score(c_d_score)
  result['c_d_score_std_deviation'] = ml_utils.std_deviation_score(c_d_score)
  result['n_nodes'] = ml_utils.average_score(n_nodes)
  result['mcc'] = ml_utils.average_score(mcc)

  local csv_path = Q_SRC_ROOT .."/ML/DT/test/b_cancer_results.csv"
  local plpretty = require 'pl.pretty'
  plpretty.dump(result)
  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
  end

-- Dataset: titanic/titanic_train_test.csv
tests.t2 = function()
  local sklearn_to_q_dt = require "Q/ML/DT/lua/sklearn_to_q_dt"
  local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
  local predict = require 'Q/ML/DT/lua/dt'['predict']
  local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
  local print_g_dt      = require 'Q/ML/DT/lua/graphviz_to_q_dt'['print_dt']
  local node_count = require 'Q/ML/DT/lua/dt'['node_count']
  local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_1'

  local features_list = { "PassengerId","Survived","Pclass","Sex","Age","SibSp","Parch","Fare","Embarked" }
  local goal_feature = "Survived"
  local D = sklearn_to_q_dt(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_titanic_accuracy.txt", features_list, goal_feature)
  -- printing the q decision tree structure in a file
  local fp = io.open(Q_SRC_ROOT .. "/ML/DT/test/t2_imported_graphviz_dt.txt", "w")
  fp:write("digraph Tree {\n")
  fp:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  fp:write("edge [fontname=helvetica] ;\n")

  print_g_dt(D, fp)
  fp:write("}\n")
  fp:close()

  -- calling the Q decision tree with same training samples as passed to sklearn
  local args = {}
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_train.csv"
  args.test_csv  = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_test.csv"
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"
  args.is_hdr = true
  args.goal = goal_feature
  args.tree = D

  local gain = {}
  local cost = {}
  local precision = {}
  local recall = {}
  local f1_score = {}
  local c_d_score = {}
  local n_nodes = {}
  local mcc = {}

  local credit_val = 0
  local debit_val = 0
      
  local Train, Test
  assert(args.test_csv)
  assert(args.meta_data_file)
  Train = Q.load_csv(args.train_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})
  Test  = Q.load_csv(args.test_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})
  local abc1, g_train, abc2, abc3, abc3 = extract_goal(Train, args.goal)
  local test,  g_test,  m_test,  n_test, test_col_name  = extract_goal(Test,  args.goal)
  local predicted_values = {}
  local actual_values = {}
  local accuracy = {}
  -- predict for test samples
  for i = 1, n_test do
    local x = {}
    for k = 1, m_test do
      x[k] = test[k]:get_one(i-1)
    end
    local n_H, n_T = predict(D, x)
    --print(type(n_H), type(n_T))
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
  local n_count = node_count(D)
  n_nodes[#n_nodes+1] = n_count

  -- calculate credit-debit score
  c_d_score[#c_d_score+1] = ( credit_val - debit_val ) / n_test

  -- calculate dt cost
  local g, c = evaluate_dt(D, g_train)
  gain[#gain+1] = g
  cost[#cost+1] = c

  -- get classification_report
  local report = ml_utils.classification_report(actual_values, predicted_values)
  accuracy[#accuracy + 1] = report["accuracy_score"]
  precision[#precision + 1] = report["precision_score"]
  recall[#recall + 1] = report["recall_score"]
  f1_score[#f1_score + 1] = report["f1_score"]
  mcc[#mcc + 1] = report["mcc"]

  local result = {}
  result['accuracy'] = ml_utils.average_score(accuracy)
  result['gain'] = ml_utils.average_score(gain)
  result['cost'] = ml_utils.average_score(cost)
  result['accuracy_std_deviation'] = ml_utils.std_deviation_score(accuracy)
  result['gain_std_deviation'] = ml_utils.std_deviation_score(gain)
  result['cost_std_deviation'] = ml_utils.std_deviation_score(cost)
  result['precision'] = ml_utils.average_score(precision)
  result['recall'] = ml_utils.average_score(recall)
  result['f1_score'] = ml_utils.average_score(f1_score)
  result['precision_std_deviation'] = ml_utils.std_deviation_score(precision)
  result['recall_std_deviation'] = ml_utils.std_deviation_score(recall)
  result['f1_score_std_deviation'] = ml_utils.std_deviation_score(f1_score)
  result['c_d_score'] = ml_utils.average_score(c_d_score)
  result['c_d_score_std_deviation'] = ml_utils.std_deviation_score(c_d_score)
  result['n_nodes'] = ml_utils.average_score(n_nodes)
  result['mcc'] = ml_utils.average_score(mcc)

  local csv_path = Q_SRC_ROOT .."/ML/DT/test/ramesh_f1_results.csv"
  local plpretty = require 'pl.pretty'
  plpretty.dump(result)
  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
  end


-- Dataset: from_ramesh/ds1_11709_13248_test.csv
tests.t3 = function()
  local sklearn_to_q_dt = require "Q/ML/DT/lua/sklearn_to_q_dt"
  local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
  local predict = require 'Q/ML/DT/lua/dt'['predict']
  local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
  local print_g_dt      = require 'Q/ML/DT/lua/graphviz_to_q_dt'['print_dt']
  local node_count = require 'Q/ML/DT/lua/dt'['node_count']
  local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_1'

  local features_list = { "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","class" }
  local goal_feature = "class"
  local D = sklearn_to_q_dt(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_ramesh_accuracy.txt", features_list, goal_feature)
  -- printing the q decision tree structure in a file
  local fp = io.open(Q_SRC_ROOT .. "/ML/DT/test/t3_imported_graphviz_dt.txt", "w")
  fp:write("digraph Tree {\n")
  fp:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  fp:write("edge [fontname=helvetica] ;\n")

  print_g_dt(D, fp)
  fp:write("}\n")
  fp:close()

  -- calling the Q decision tree with same training samples as passed to sklearn
  local args = {}
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_test.csv"
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  args.is_hdr = true
  args.goal = "class"
  args.tree = D

  local gain = {}
  local cost = {}
  local precision = {}
  local recall = {}
  local f1_score = {}
  local c_d_score = {}
  local n_nodes = {}
  local mcc = {}

  local credit_val = 0
  local debit_val = 0
      
  local Train, Test
  assert(args.test_csv)
  assert(args.meta_data_file)
  Train = Q.load_csv(args.train_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})
  Test  = Q.load_csv(args.test_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})
  local abc1, g_train, abc2, abc3, abc3 = extract_goal(Train, args.goal)
  local test,  g_test,  m_test,  n_test, test_col_name  = extract_goal(Test,  args.goal)
  local predicted_values = {}
  local actual_values = {}
  local accuracy = {}
  -- predict for test samples
  for i = 1, n_test do
    local x = {}
    for k = 1, m_test do
      x[k] = test[k]:get_one(i-1)
    end
    local n_H, n_T = predict(D, x)
    --print(type(n_H), type(n_T))
    local decision
    if n_H > n_T then
      decision = 1 
    else
      decision = 0
    end
    predicted_values[i] = decision
    actual_values[i] = g_test:get_one(i-1):to_num()
    --print(( n_H / ( n_H + n_T ) ))
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
  local n_count = node_count(D)
  n_nodes[#n_nodes+1] = n_count

  -- calculate credit-debit score
  c_d_score[#c_d_score+1] = ( credit_val - debit_val ) / n_test

  -- calculate dt cost
  local g, c = evaluate_dt(D, g_train)
  gain[#gain+1] = g
  cost[#cost+1] = c

  -- get classification_report
  local report = ml_utils.classification_report(actual_values, predicted_values)
  accuracy[#accuracy + 1] = report["accuracy_score"]
  precision[#precision + 1] = report["precision_score"]
  recall[#recall + 1] = report["recall_score"]
  f1_score[#f1_score + 1] = report["f1_score"]
  mcc[#mcc + 1] = report["mcc"]

  local result = {}
  result['accuracy'] = ml_utils.average_score(accuracy)
  result['gain'] = ml_utils.average_score(gain)
  result['cost'] = ml_utils.average_score(cost)
  result['accuracy_std_deviation'] = ml_utils.std_deviation_score(accuracy)
  result['gain_std_deviation'] = ml_utils.std_deviation_score(gain)
  result['cost_std_deviation'] = ml_utils.std_deviation_score(cost)
  result['precision'] = ml_utils.average_score(precision)
  result['recall'] = ml_utils.average_score(recall)
  result['f1_score'] = ml_utils.average_score(f1_score)
  result['precision_std_deviation'] = ml_utils.std_deviation_score(precision)
  result['recall_std_deviation'] = ml_utils.std_deviation_score(recall)
  result['f1_score_std_deviation'] = ml_utils.std_deviation_score(f1_score)
  result['c_d_score'] = ml_utils.average_score(c_d_score)
  result['c_d_score_std_deviation'] = ml_utils.std_deviation_score(c_d_score)
  result['n_nodes'] = ml_utils.average_score(n_nodes)
  result['mcc'] = ml_utils.average_score(mcc)

  local csv_path = Q_SRC_ROOT .."/ML/DT/test/ramesh_f1_results.csv"
  local plpretty = require 'pl.pretty'
  plpretty.dump(result)
  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
end

return tests