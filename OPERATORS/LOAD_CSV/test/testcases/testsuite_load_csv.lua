-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local fns = require 'Q/OPERATORS/LOAD_CSV/test/testcases/handle_category'
local utils = require 'Q/UTILS/lua/utils'
local dir = require 'pl.dir'
local plpath = require 'pl.path'

local script_dir = "/home/pragati/WORK/Q/OPERATORS/LOAD_CSV/test/testcases/"

local test_input_dir = script_dir .."/test_data/"
local test_metadata_dir = script_dir .."/test_metadata/"

local T = dofile(script_dir .."/map_metadata_data.lua")

local test_load = {}
--local pretty = require 'pl.pretty'

for i, v in ipairs(T) do

  test_load["execute"..i] = function()
    
    print("Running testcase " .. v.testcase_no ..": ".. v.name)
    local M = dofile(test_metadata_dir..v.meta)
    local D = v.data
    local opt_args = v.opt_args
    local result
    
    local status, ret = pcall(load_csv,test_input_dir..D,  M, opt_args)
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
  end
  
end
-- pretty.dump(test_s)
return test_load