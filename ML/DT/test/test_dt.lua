local Q = require 'Q'
local run_dt = require 'Q/ML/DT/lua/run_dt'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")

local tests = {}
tests.t1 = function()
  local data_file = Q_SRC_ROOT .. "/ML/KNN/data/occupancy/occupancy.csv"
  local metadata_file = Q_SRC_ROOT .. "/ML/KNN/data/occupancy/occupancy_meta.lua"

  local args = {}
  args.meta_data_file = metadata_file
  args.data_file = data_file
  args.goal = "occupy_status"

  local average_acr, accuracy_table = run_dt(args)
  print(average_acr)
end


return tests
