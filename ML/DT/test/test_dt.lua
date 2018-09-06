local Q = require 'Q'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local run_dt = require 'Q/ML/DT/lua/run_dt'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")

local tests = {}
tests.t1 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/occupancy/occupancy.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/occupancy/occupancy_meta.lua"
  local alpha = Scalar.new(1.256, "F4")

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
  local alpha = Scalar.new(0.75, "F4")

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

return tests
