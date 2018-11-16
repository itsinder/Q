local Q = require 'Q'
local gini_to_q_graphviz = require 'Q/ML/DT/lua/sklearn_to_q_graphviz'['gini_to_q_graphviz']
local load_csv_col_seq = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
local graphviz_to_D = require 'Q/ML/DT/lua/graphviz_to_q_dt'['graphviz_to_D']
local print_g_dt      = require 'Q/ML/DT/lua/graphviz_to_q_dt'['print_dt']
local predict = require 'Q/ML/DT/lua/dt'['predict']
local ml_utils = require 'Q/ML/UTILS/lua/ml_utils'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local run_dt = require 'Q/ML/DT/lua/run_dt'
local split = require 'Q/ML/UTILS/lua/split_csv_to_train_test'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local plpath = require 'pl.path'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/ML/DT/test/"
assert(plpath.isdir(path_to_here))

local tests = {}

tests.t1 = function()
  
  -- splitting the data
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  local split_csv_args = {}
  split_csv_args.is_hdr = true
  local hdr_info = "id,diagnosis,radius_mean,texture_mean,perimeter_mean,area_mean,smoothness_mean,compactness_mean,concavity_mean,concave points_mean,symmetry_mean,fractal_dimension_mean,radius_se,texture_se,perimeter_se,area_se,smoothness_se,compactness_se,concavity_se,concave points_se,symmetry_se,fractal_dimension_se,radius_worst,texture_worst,perimeter_worst,area_worst,smoothness_worst,compactness_worst,concavity_worst,concave points_worst,symmetry_worst,fractal_dimension_worst" 
  split(data_file, metadata_file, split_csv_args, hdr_info)

  -- executing the sklearn gini and entropy
  local cmd = "python -Wignore " .. Q_SRC_ROOT .. "/ML/DT/python/DTree_sklearn_breast_cancer_train_test.py"
  os.execute(cmd)
  
  -- converting sklearn gini graphviz to q graphviz format
  gini_to_q_graphviz(Q_SRC_ROOT .."/ML/DT/python/graphviz_gini.txt")
  
  -- converting q graphviz format file to Q dt
  -- ( i.e. loading q graphviz to q data structure)
  local features_list = {"radius_worst","fractal_dimension_worst","texture_se","id","symmetry_worst","fractal_dimension_se","concavity_worst","compactness_worst","texture_mean","smoothness_worst","concave points_se","perimeter_worst","area_mean","texture_worst","radius_mean","concavity_mean","concavity_se","concave points_mean","concave points_worst","symmetry_se","area_worst","symmetry_mean","area_se","smoothness_mean","smoothness_se","compactness_se","perimeter_mean","compactness_mean","perimeter_se","radius_se","fractal_dimension_mean"}
  
  local file = Q_SRC_ROOT .. "gini_to_q_graphviz.txt"
  local goal_feature = "diagnosis"
  --local new_features_list = load_csv_col_seq(features_list, goal_feature)
  local D = graphviz_to_D(file, features_list)
  
  -- printing the q decision tree structure in a file
  local fp = io.open(path_to_here .. "graphviz_dt.txt", "w")
  fp:write("digraph Tree {\n")
  fp:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  fp:write("edge [fontname=helvetica] ;\n")

  print_g_dt(D, fp)
  fp:write("}\n")
  fp:close()

  --local status = os.execute("diff " .. file .. " graphviz_dt.txt")
  --assert(status == 0, "graphviz.txt and graphviz_dt files not matched")
  print("Successfully created D from graphviz file")

  -- calling the Q decision tree with same training samples as passed to sklearn
  local args = {}
  args.data_file = nil
  args.test_csv = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data_test.csv"
  args.meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  args.is_hdr = true
  args.goal = "diagnosis"
  args.alpha =  Scalar.new(0.2, "F4")
  args.tree = D

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local Test
  assert(args.test_csv)
  Test = Q.load_csv(args.test_csv, dofile(args.meta_data_file), {is_hdr = args.is_hdr})

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
    local n_H, n_T = predict(args.tree, x, i)
    local decision
    if n_H > n_T then
      decision = 1 
    else
      decision = 0
    end
    predicted_values[i] = decision
    actual_values[i] = g_test:get_one(i-1):to_num()
  end

  local acr = ml_utils.accuracy_score(actual_values, predicted_values)
  accuracy[#accuracy + 1] = acr
  local average_acr =  ml_utils.average_score(accuracy), accuracy
  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
  print("Q dt Accuracy = " .. tostring(average_acr))
  --[[
  if _G['g_time'] then
    for k, v in pairs(_G['g_time']) do
      local niters  = _G['g_ctr'][k] or "unknown"
      local ncycles = tonumber(v)
      print("0," .. k .. "," .. niters .. "," .. ncycles)
    end
  end
  print("================================================")
  ]]
  assert(average_acr == 92.43986254295532, "Different accuracy returned by sklearn and Q.dt")
end

return tests