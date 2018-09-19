local Q = require 'Q'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local run_dt = require 'Q/ML/DT/lua/run_dt'
local calculate_alpha = require 'Q/ML/DT/lua/calculate_alpha'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")

local tests = {}
tests.t1 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/occupancy/occupancy.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/occupancy/occupancy_meta.lua"
  local alpha = Scalar.new(0.3, "F4")

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "occupy_status"
  args.alpha = alpha

  Vector.reset_timers()
  start_time = qc.RDTSC()
  local average_acr, accuracy_table = run_dt(args)
  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
  print("Accuracy = " .. tostring(average_acr))
end

tests.t2 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_data.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/cancer/b_cancer/cancer_meta.lua"
  local alpha = Scalar.new(0.3, "F4")

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "diagnosis"
  args.alpha = alpha

  Vector.reset_timers()
  start_time = qc.RDTSC()
  local average_acr, accuracy_table = run_dt(args)
  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
  print("Accuracy = " .. tostring(average_acr))
end

tests.t3 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"
  local alpha = Scalar.new(0.3, "F4")

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "Survived"
  args.alpha = alpha

  Vector.reset_timers()
  start_time = qc.RDTSC()
  local average_acr, accuracy_table = run_dt(args)
  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
  print("Accuracy = " .. tostring(average_acr))
end


tests.t4 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  local alpha = Scalar.new(0.2, "F4")

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "class"
  args.alpha = alpha

  Vector.reset_timers()
  start_time = qc.RDTSC()
  local average_acr, accuracy_table = run_dt(args)
  stop_time = qc.RDTSC()
  --Vector.print_timers()
  print("================================================")
  print("total execution time : " .. tostring(tonumber(stop_time-start_time)))
  print("================================================")
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
  print("Accuracy = " .. tostring(average_acr))
end


tests.t5 = function()
  -- Test alpha calculation
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "Survived"
  args.iterations = 3
  args.min_alpha = 0.2
  args.max_alpha = 0.5
  args.step_alpha = 0.1

  Vector.reset_timers()
  start_time = qc.RDTSC()

  local result = calculate_alpha(args)

  for i, v in pairs(result) do
    print(i, v)
  end

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

  print("alpha & gain table")
  for i, v in pairs(gain) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost table")
  for i, v in pairs(cost) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy table")
  for i, v in pairs(accuracy) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy_std_deviation table")
  for i, v in pairs(accuracy_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & gain_std_deviation table")
  for i, v in pairs(gain_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost_std_deviation table")
  for i, v in pairs(cost_std_deviation) do
    print(i, v)
  end
  print("================================================")

end

tests.t6 = function()
  -- Test alpha calculation
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "class"
  args.iterations = 3
  args.min_alpha = 0.2
  args.max_alpha = 0.5
  args.step_alpha = 0.1

  Vector.reset_timers()
  start_time = qc.RDTSC()

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

  print("alpha & gain table")
  for i, v in pairs(gain) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost table")
  for i, v in pairs(cost) do
    print(i, v)
  end
  print("================================================")
  print("alpha & accuracy table")
  for i, v in pairs(accuracy) do
    print(i, v)
  end
  print("================================================")
  --[[
  print("alpha & accuracy_std_deviation table")
  for i, v in pairs(accuracy_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & gain_std_deviation table")
  for i, v in pairs(gain_std_deviation) do
    print(i, v)
  end
  print("================================================")
  print("alpha & cost_std_deviation table")
  for i, v in pairs(cost_std_deviation) do
    print(i, v)
  end
  print("================================================")
  ]]
end

return tests
