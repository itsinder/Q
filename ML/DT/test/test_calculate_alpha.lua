local Q = require 'Q'
local Vector = require 'libvec'
local tablex = require 'pl.tablex'
local calculate_alpha = require 'Q/ML/DT/lua/calculate_alpha'
local write_to_csv = require 'Q/ML/DT/lua/write_to_csv'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")

local tests = {}

tests.t1 = function()
  -- Test alpha calculation
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "Survived"
  args.iterations = 10
  args.min_alpha = 0.15
  args.max_alpha = 0.7
  args.step_alpha = 0.01
  args.split_ratio = 0.5
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = calculate_alpha(args)
  local csv_path = "titanic_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)

  --[[
  local accuracy = result['accuracy']
  local accuracy_std_deviation = result['accuracy_std_deviation']
  local gain = result['gain']
  local gain_std_deviation = result['gain_std_deviation']
  local cost = result['cost']
  local cost_std_deviation = result['cost_std_deviation']

  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
  ]]
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

  --[[
  print("alpha & gain table")
  for i, v in tablex.sort(gain) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost table")
  for i, v in tablex.sort(cost) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy table")
  for i, v in tablex.sort(accuracy) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy_std_deviation table")
  for i, v in tablex.sort(accuracy_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & gain_std_deviation table")
  for i, v in tablex.sort(gain_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost_std_deviation table")
  for i, v in tablex.sort(cost_std_deviation) do
    print(i, v)
  end
  print("================================================")
  ]]
end

tests.t2 = function()
  -- Test alpha calculation
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "class"
  args.iterations = 10
  args.min_alpha = 0.15
  args.max_alpha = 0.7
  args.step_alpha = 0.01
  args.split_ratio = 0.5
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = calculate_alpha(args)
  local csv_path = "ramesh's_dataset_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)

  --[[
  local accuracy = result['accuracy']
  local accuracy_std_deviation = result['accuracy_std_deviation']
  local gain = result['gain']
  local gain_std_deviation = result['gain_std_deviation']
  local cost = result['cost']
  local cost_std_deviation = result['cost_std_deviation']

  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
  ]]
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
  --[[
  print("alpha & gain table")
  for i, v in tablex.sort(gain) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost table")
  for i, v in tablex.sort(cost) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy table")
  for i, v in tablex.sort(accuracy) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy_std_deviation table")
  for i, v in tablex.sort(accuracy_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & gain_std_deviation table")
  for i, v in tablex.sort(gain_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost_std_deviation table")
  for i, v in tablex.sort(cost_std_deviation) do
    print(i, v)
  end
  print("================================================")
  ]]
end


tests.t3 = function()
  -- Test alpha calculation
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"


  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.is_hdr = true
  args.goal = "diagnosis"
  args.iterations = 2
  args.min_alpha = 0.15
  args.max_alpha = 0.7
  args.step_alpha = 0.01
  args.split_ratio = 0.5
  args.is_hdr = true

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = calculate_alpha(args)
  local csv_path = "b_cancer_results.csv"

  write_to_csv(result, csv_path)
  print("Results written to " .. csv_path)

  --[[
  local accuracy = result['accuracy']
  local accuracy_std_deviation = result['accuracy_std_deviation']
  local gain = result['gain']
  local gain_std_deviation = result['gain_std_deviation']
  local cost = result['cost']
  local cost_std_deviation = result['cost_std_deviation']
  local precision = result['precision']
  local precision_std_deviation = result['precision_std_deviation']
  local recall = result['recall']
  local recall_std_deviation = result['recall_std_deviation']
  local f1_score = result['f1_score']
  local f1_score_std_deviation = result['f1_score_std_deviation']


  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
  ]]
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

  --[[
  print("alpha & gain table")
  for i, v in tablex.sort(gain) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost table")
  for i, v in tablex.sort(cost) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy table")
  for i, v in tablex.sort(accuracy) do
    print(i, v)
  end
  print("================================================")
  print("alpha & precision table")
  for i, v in tablex.sort(precision) do
    print(i, v)
  end
  print("================================================")
  print("alpha & recall table")
  for i, v in tablex.sort(recall) do
    print(i, v)
  end
  print("================================================")
  print("alpha & f1_score table")
  for i, v in tablex.sort(f1_score) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy_std_deviation table")
  for i, v in tablex.sort(accuracy_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & gain_std_deviation table")
  for i, v in tablex.sort(gain_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost_std_deviation table")
  for i, v in tablex.sort(cost_std_deviation) do
    print(i, v)
  end
  print("================================================")
  ]]
end

return tests
