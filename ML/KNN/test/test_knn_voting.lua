local Q = require 'Q'
local plpath = require 'pl.path'
local run_voting = require 'Q/ML/KNN/lua/run_voting'
-- local utils = require 'Q/UTILS/lua/utils'
local tests = {}

local q_src_root = os.getenv("Q_SRC_ROOT")
assert(plpath.isdir(q_src_root))
local data_dir = q_src_root .. "/ML/KNN/data/"
assert(plpath.isdir(data_dir))

tests.t1 = function()
  languages = { "C", "Lua" }
  for _, language in ipairs(languages) do 
    inputs = {
      meta_data_file = data_dir .. "/occupancy/occupancy_meta.lua",
      data_file      = data_dir .. "/occupancy/occupancy.csv",
      split_ratio    = 0.8,
      goal           = "occupy_status",
      language       = language
    }
    ret_vals = run_voting(inputs)
  end
  print("Test t1 completed")
end
tests.t1()
return tests
