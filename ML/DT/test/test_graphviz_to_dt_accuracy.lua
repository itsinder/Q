local Q = require 'Q'
local Scalar = require 'libsclr'
local graphviz_to_D = require 'Q/ML/DT/lua/graphviz_to_q_dt'['graphviz_to_D']
local print_g_dt      = require 'Q/ML/DT/lua/graphviz_to_q_dt'['print_dt']
local load_csv_col_seq = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
local make_dt = require 'Q/ML/DT/lua/dt'['make_dt']
local predict = require 'Q/ML/DT/lua/dt'['predict']
local check_dt = require 'Q/ML/DT/lua/dt'['check_dt']
local print_dt = require 'Q/ML/DT/lua/dt'['print_dt']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local plpath        = require 'pl.path'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/ML/DT/test/"
assert(plpath.isdir(path_to_here))

local tests = {}
tests.t1 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  local alpha = Scalar.new(0.3, "F4")

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "diagnosis"
  args.alpha = alpha
  args.split_ratio = 0.7

  -- load the data
  local T = Q.load_csv(data_file, dofile(args.meta_data_file), {is_hdr = true})

  local accuracy = {}
  -- break into a training set and a testing set
  local Train, Test, col_n
  Train, Test, col_n = split_train_test(T, args.split_ratio, args.feature_of_interest, 100)

  local train, g_train, m_train, n_train, train_col_name = extract_goal(Train, args.goal)
  local test,  g_test,  m_test,  n_test, test_col_name  = extract_goal(Test,  args.goal)

  -- Current implementation assumes 2 values of goal as 0, 1
  local min_g, _ = Q.min(g_train):eval()
  assert(min_g:to_num() == 0)
  local max_g, _ = Q.max(g_train):eval()
  assert(max_g:to_num() == 1)

  local predicted_values = {}

  -- prepare decision tree
  local tree = make_dt(train, g_train, alpha)
  assert(tree)

  -- verify the decision tree
  check_dt(tree)

  -- print decision tree
  local f = io.open(path_to_here .. "graphviz.txt", "a")
  f:write("digraph Tree {\n")
  f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  f:write("edge [fontname=helvetica] ;\n")
  print_dt(tree, f, train_col_name)
  f:write("}\n")
  f:close()

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
    predicted_values[#predicted_values+1] = decision
  end

  -- prepare table of actual goal values
  local actual_values = {}
  for k = 1, n_test do
    actual_values[k] = g_test:get_one(k-1):to_num()
  end

  local acr_dt = ml_utils.accuracy_score(actual_values, predicted_values)
  -- print("Accuracy: " .. tostring(acr))
  accuracy[#accuracy + 1] = acr_dt

  print("Accuracy of old DT = " .. tostring(ml_utils.average_score(accuracy)))
  print("================================================")
  
  local features_list = { "id", "diagnosis", "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean","compactness_mean", "concavity_mean", "concave points_mean", "symmetry_mean", "fractal_dimension_mean", "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concave points_se", "symmetry_se", "fractal_dimension_se", "radius_worst","texture_worst", "perimeter_worst", "area_worst", "smoothness_worst","compactness_worst", "concavity_worst", "concave points_worst", "symmetry_worst", "fractal_dimension_worst" }
  
  local file = path_to_here .. "graphviz.txt"
  local goal_feature = "diagnosis"
  local new_features_list = load_csv_col_seq(features_list, goal_feature)
  local D = graphviz_to_D(file, new_features_list)
  
  local fp = io.open(path_to_here .. "graphviz_dt.txt", "w")
  fp:write("digraph Tree {\n")
  fp:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  fp:write("edge [fontname=helvetica] ;\n")

  -- print decision tree in a file
  print_g_dt(D, fp)
  fp:write("}\n")
  fp:close()
  local status = os.execute("diff " .. file .. " " ..  path_to_here .. "graphviz_dt.txt")
  assert(status == 0, "graphviz.txt and graphviz_dt files not matched")
  print("Successfully created D from graphviz file")
  
  local predicted_values_test = {}
  -- predict for test samples
  for i = 1, n_test do
    local x = {}
    for k = 1, m_test do
      x[k] = test[k]:get_one(i-1)
    end
    local n_H, n_T = predict(D, x)
    local decision
    if n_H > n_T then
      decision = 1 
    else
      decision = 0
    end
    predicted_values_test[#predicted_values_test+1] = decision
  end
  
  local accuracy_test = {}
  -- prepare table of actual goal values
  local actual_values_test = {}
  for k = 1, n_test do
    actual_values_test[k] = g_test:get_one(k-1):to_num()
  end

  local acr_dt_new = ml_utils.accuracy_score(actual_values_test, predicted_values_test)
  -- print("Accuracy: " .. tostring(acr))
  accuracy_test[#accuracy_test + 1] = acr_dt_new
  local average_acr = ml_utils.average_score(accuracy_test)
  
  print("Accuracy of new DT = " .. tostring(average_acr))
  print("================================================")
  assert(acr_dt_new == acr_dt, "Accuracy not same")
end

return tests
