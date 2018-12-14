local Q = require 'Q'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")

local tests = {}

-- Dataset: b_cancer/cancer_data_test.csv
tests.t1 = function()
  local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
  local predict = require 'Q/ML/DT/lua/dt'['predict']
  local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
  local node_count = require 'Q/ML/DT/lua/dt'['node_count']
  local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_1'
  local preprocess_dt = require 'Q/ML/DT/lua/dt'['preprocess_dt']
  local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
  local load_csv_col_seq   = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
  local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

  local features_list = { "id", "diagnosis", "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean","compactness_mean", "concavity_mean", "concave points_mean", "symmetry_mean", "fractal_dimension_mean", "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concave points_se", "symmetry_se", "fractal_dimension_se", "radius_worst","texture_worst", "perimeter_worst", "area_worst", "smoothness_worst","compactness_worst", "concavity_worst", "concave points_worst", "symmetry_worst", "fractal_dimension_worst" }

  local goal_feature = "diagnosis"

  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_b_cancer_accuracy.txt", features_list, goal_feature)

  -- perform the preprocess activity
  -- initializes n_H1 and n_T1 to zero
  preprocess_dt(tree)

  -- printing the decision tree in gini graphviz format
  features_list = load_csv_col_seq(features_list, goal_feature)
  local file_name = Q_SRC_ROOT .. "/ML/DT/test/test_accuracy_results/t1_imported_graphviz_accuracy_dt.txt"
  export_to_graphviz(file_name, tree, features_list)

  -- calling the Q decision tree with same training samples as passed to sklearn
  local args = {}
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data_train.csv"
  args.test_csv  = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data_test.csv"
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  args.is_hdr = true
  args.goal = goal_feature
  args.tree = tree

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
  -- Train = Q.load_csv(args.train_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})
  Test  = Q.load_csv(args.test_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})
  -- local abc1, g_train, abc2, abc3, abc3 = extract_goal(Train, args.goal)
  local test,  g_test,  m_test,  n_test, test_col_name  = extract_goal(Test,  args.goal)
  local predicted_values = {}
  local actual_values = {}
  local accuracy = {}

  -- predict for test samples
  for i = 1, n_test do
    local x = {}
    local actual_value = g_test:get_one(i-1):to_num()
    for k = 1, m_test do
      x[k] = test[k]:get_one(i-1):to_num()
    end
    local n_H, n_T = predict(args.tree, x, actual_value )
    n_H = n_H
    n_T = n_T
    local decision
    if n_H > n_T then
      decision = 1 
    else
      decision = 0
    end
    predicted_values[i] = decision
    actual_values[i] = actual_value
  end

  -- calculate dt cost
  local payout = evaluate_dt(args.tree)

  -- get classification_report
  local report = ml_utils.classification_report(actual_values, predicted_values)
  report.payout = payout

  local csv_path = Q_SRC_ROOT .."/ML/DT/test/test_accuracy_results/b_cancer_accuracy_results.csv"
  local plpretty = require 'pl.pretty'
  plpretty.dump(report)
  write_to_csv(report, csv_path)
  print("Results written to " .. csv_path)
  end

-- Dataset: titanic/titanic_train_test.csv
tests.t2 = function()
  local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
  local predict = require 'Q/ML/DT/lua/dt'['predict']
  local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
  local node_count = require 'Q/ML/DT/lua/dt'['node_count']
  local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_1'
  local preprocess_dt = require 'Q/ML/DT/lua/dt'['preprocess_dt']
  local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
  local print_dt = require 'Q/ML/DT/lua/dt'['print_dt']
  local load_csv_col_seq   = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
  local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

  local features_list = { "PassengerId","Survived","Pclass","Sex","Age","SibSp","Parch","Fare","Embarked" }
  local goal_feature = "Survived"

  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_titanic_accuracy.txt", features_list, goal_feature)

  -- perform the preprocess activity
  -- initializes n_H1 and n_T1 to zero
  preprocess_dt(tree)

  -- printing the decision tree in gini graphviz format
  features_list = load_csv_col_seq(features_list, goal_feature)
  local file_name = Q_SRC_ROOT .. "/ML/DT/test/test_accuracy_results/t2_imported_graphviz_accuracy_dt.txt"
  export_to_graphviz(file_name, tree, features_list)

  -- calling the Q decision tree with same training samples as passed to sklearn
  local args = {}
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_train.csv"
  args.test_csv  = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_test.csv"
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"
  args.is_hdr = true
  args.goal = goal_feature
  args.tree = tree

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
      x[k] = test[k]:get_one(i-1):to_num()
    end
    local n_H, n_T = predict(args.tree, x)
    n_H = n_H
    n_T = n_T
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
    n_H_prob = ( n_H / ( n_H + n_T ) )
    n_T_prob = ( n_T / ( n_H + n_T ) )
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
  local n_count = node_count(args.tree)
  n_nodes[#n_nodes+1] = n_count

  -- calculate credit-debit score
  c_d_score[#c_d_score+1] = ( credit_val - debit_val ) / n_test

  -- calculate dt cost
  local g, c = evaluate_dt( args.tree, g_train)
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

  local csv_path = Q_SRC_ROOT .."/ML/DT/test/test_accuracy_results/titanic_accuracy_results.csv"
  local plpretty = require 'pl.pretty'
  plpretty.dump(result)
  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
  end


-- Dataset: from_ramesh/ds1_11709_13248_test.csv
tests.t3 = function()
  local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
  local predict = require 'Q/ML/DT/lua/dt'['predict']
  local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
  local node_count = require 'Q/ML/DT/lua/dt'['node_count']
  local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_1'
  local preprocess_dt = require 'Q/ML/DT/lua/dt'['preprocess_dt']
  local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
  local print_dt = require 'Q/ML/DT/lua/dt'['print_dt']
  local load_csv_col_seq   = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
  local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

  local features_list = { "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","class" }
  local goal_feature = "class"

  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_ramesh_accuracy.txt", features_list, goal_feature)

  -- perform the preprocess activity
  -- initializes n_H1 and n_T1 to zero
  preprocess_dt(tree)

  -- printing the decision tree in gini graphviz format
  features_list = load_csv_col_seq(features_list, goal_feature)
  local file_name = Q_SRC_ROOT .. "/ML/DT/test/test_accuracy_results/t3_imported_graphviz_dt.txt"
  export_to_graphviz(file_name, tree, features_list)

  -- calling the Q decision tree with same training samples as passed to sklearn
  local args = {}
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_test.csv"
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  args.is_hdr = true
  args.goal = "class"
  args.tree = tree

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
      x[k] = test[k]:get_one(i-1):to_num()
    end
    local n_H, n_T = predict(args.tree, x)
    n_H = n_H
    n_T = n_T
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
    n_H_prob = ( n_H / ( n_H + n_T ) )
    n_T_prob = ( n_T / ( n_H + n_T ) )
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
  local n_count = node_count(args.tree)
  n_nodes[#n_nodes+1] = n_count

  -- calculate credit-debit score
  c_d_score[#c_d_score+1] = ( credit_val - debit_val ) / n_test

  -- calculate dt cost
  local g, c = evaluate_dt(args.tree, g_train)
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

  local csv_path = Q_SRC_ROOT .."/ML/DT/test/test_accuracy_results/ramesh_accuracy_results.csv"
  local plpretty = require 'pl.pretty'
  plpretty.dump(result)
  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
end

-- Dataset: from_ramesh/ds2_11720_7137_test.csv
tests.t4 = function()
  local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
  local predict = require 'Q/ML/DT/lua/dt'['predict']
  local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
  local node_count = require 'Q/ML/DT/lua/dt'['node_count']
  local evaluate_dt = require 'Q/ML/DT/lua/evaluate_dt'['evaluate_dt']
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_1'
  local preprocess_dt = require 'Q/ML/DT/lua/dt'['preprocess_dt']
  local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
  local print_dt = require 'Q/ML/DT/lua/dt'['print_dt']
  local load_csv_col_seq   = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
  local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

  local features_list = { "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","class" }
  local goal_feature = "class"

  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_ramesh_category2_f1.txt", features_list, goal_feature)

  -- perform the preprocess activity
  -- initializes n_H1 and n_T1 to zero
  preprocess_dt(tree)

  -- printing the decision tree in gini graphviz format
  features_list = load_csv_col_seq(features_list, goal_feature)
  local file_name = Q_SRC_ROOT .. "/ML/DT/test/test_accuracy_results/t4_imported_graphviz_f1_dt.txt"
  export_to_graphviz(file_name, tree, features_list)

  -- calling the Q decision tree with same training samples as passed to sklearn
  local args = {}
  args.data_file = nil
  args.train_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_train.csv"
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_test.csv"
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  args.is_hdr = true
  args.goal = "class"
  args.tree = tree

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
      x[k] = test[k]:get_one(i-1):to_num()
    end
    local n_H, n_T = predict(args.tree, x)
    n_H = n_H
    n_T = n_T
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
    n_H_prob = ( n_H / ( n_H + n_T ) )
    n_T_prob = ( n_T / ( n_H + n_T ) )
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
  local n_count = node_count(args.tree)
  n_nodes[#n_nodes+1] = n_count

  -- calculate credit-debit score
  c_d_score[#c_d_score+1] = ( credit_val - debit_val ) / n_test

  -- calculate dt cost
  local g, c = evaluate_dt(args.tree, g_train)
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

  local csv_path = Q_SRC_ROOT .."/ML/DT/test/test_accuracy_results/ramesh_category2_f1_results.csv"
  local plpretty = require 'pl.pretty'
  plpretty.dump(result)
  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)
end

return tests
