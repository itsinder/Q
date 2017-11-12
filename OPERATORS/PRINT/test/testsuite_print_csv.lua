-- FUNCTIONAL

local fns = require 'Q/OPERATORS/PRINT/test/handle_category_print'
local file = require 'pl.file'
local dir = require 'pl.dir'
local print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local utils = require 'Q/UTILS/lua/utils'
local plpath = require 'pl.path'

local script_dir = plpath.dirname(plpath.abspath(arg[1]))
local test_input_dir = script_dir .."/test_data/"
local print_out_dir = script_dir .."/test_print_data/print_tmp/"

-- command setting which needs to be done for all test-cases
if plpath.isdir(script_dir .."/test_print_data") then 
  dir.rmtree(script_dir .."/test_print_data")
end
dir.makepath(script_dir .."/test_print_data/print_tmp/")
--set environment variables for test-case (LOAD CSV) 
-- _G["Q_DATA_DIR"] = "./test_data/out/"
-- _G["Q_META_DATA_DIR"] = "./test_data/metadata/"

-- dir.makepath(_G["Q_DATA_DIR"])
-- dir.makepath(_G["Q_META_DATA_DIR"])

local T = dofile(script_dir .."/map_metadata_data.lua")

local test_print = {}

-- Test Case Start ---------------
for i, v in ipairs(T) do
  assert(v.testcase_no,"Specify testcase_no in map file for '" .. v.name .. "' testcase")
  test_print[v.testcase_no] = function()

    print("Running testcase " .. v.testcase_no ..": " .. v.name)
    local M = dofile(script_dir .."/test_metadata/" .. v.meta)
    local D = v.data
    local F = v.filter
    local csv_file = v.csv_file
    local result
    if v.category == "category6" then
      local key = "handle_"..v.category
      if fns[key] then
        local status = fns[key](i, v, M)
        -- preamble
        utils["testcase_results"](v, "Print_csv", "Unit Test", status, "")
        assert(status,"handle " .. v.category .. " assertions failed")
      else
        fns["increment_failed"](i, v, "Handle function for "..v.category.." is not defined in handle_category.lua")
        -- preamble
        utils["testcase_results"](v, "Print_csv", "Unit Test", false, "")
        assert(fns[key], "handle category is not defined in handle_category_print.lua file") 
      end
      goto skip
    end
    
    local status, load_ret = pcall(load_csv,script_dir .."/test_data/"..D, M, {use_accelerator = false})
    if status then
      -- Persist vector or else input csv get deleted
      --for i=1, #load_ret do
      --  load_ret[i]:persist(true)
      --end
      -- if handle_input_function is present, then filter is taken from the output of this function
      -- in other cases , filter object is taken from metadata
      local key = "handle_input_"..v.category
      if fns[key] then
        F = fns[key]()
      end
      local file_path 
      if csv_file then file_path = print_out_dir .. csv_file end
      if csv_file == "" then file_path = "" end
      
      local status, print_ret = pcall(print_csv, load_ret, F, file_path)
      key = "handle_"..v.category
      if fns[key] then
        result = fns[key](i, v,  file_path, print_ret, status)
        -- preamble
        utils["testcase_results"](v, "Print_csv", "Unit Test", result, "")
        assert(result,"handle " .. v.category .. " assertions failed")
      else
        fns["increment_failed"](i, v, "Handle function for "..v.category.." is not defined in handle_category.lua")
        -- preamble
        utils["testcase_results"](v, "Print_csv", "Unit Test", false, "")
        assert(fns[key], "handle category is not defined in handle_category_print.lua file") 
      end
    else
      --print(" testcase failed: load api failed in print testcase. this should not happen")
      fns["increment_failed"](i, v, " testcase failed: load api failed in print testcase. this should not happen")
      utils["testcase_results"](v, "Print_csv", "Unit Test", status, "")
      assert(status)
    end
    ::skip::
  end
end
return test_print 