local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local fns = require 'Q/OPERATORS/LOAD_CSV/test/testcases/handle_category'
local utils = require 'Q/UTILS/lua/utils'
local dir = require 'pl.dir'

local test_input_dir = "./test_data/"
local test_metadata_dir ="./test_metadata/"
-- common setting (SET UPS) which needs to be done for all test-cases
--set environment variables for test-case
-- Q_DATA_DIR is the folder where the binary files are created
-- _G["Q_DATA_DIR"] = "./test_data/out/"
-- _G["Q_META_DATA_DIR"] = "./test_data/metadata/"
-- dir.makepath(_G["Q_DATA_DIR"])
-- dir.makepath(_G["Q_META_DATA_DIR"])

-- loop through testcases
-- these testcases output error messages
local T = dofile("map_metadata_data.lua")
for i, v in ipairs(T) do
  if arg[1] and i ~= tonumber(arg[1]) then 
    goto skip 
  end
  
  print("--------------------------------")
  local M = dofile(test_metadata_dir..v.meta)
  local D = v.data
  local result
  
  local status, ret = pcall(load_csv,test_input_dir..D,  M)
  --local status, ret = load_csv(test_input_dir..D,  M)
  local key = "handle_"..v.category
  if fns[key] then
    result = fns[key](i, status, ret, v)
    -- print("see", result)
  else
    fns["increment_failed_load"](i, v, "Handle function for "..v.category.." is not defined in handle_category.lua")
    result = false
  end
  utils["testcase_results"](v, "Load_csv", "Unit Test", result, "")
  ::skip::
end

fns["print_result"]()

-- _G["Q_DATA_DIR"] = "./test_data/out/"
-- _G["Q_META_DATA_DIR"] = "./test_data/metadata/"
-- common cleanup (TEAR DOWN) for all testcases
-- clear the output directory
-- remove all the binary files created in the testcases
-- dir.rmtree(_G["Q_DATA_DIR"])
--dir.rmtree(_G["Q_META_DATA_DIR"])
