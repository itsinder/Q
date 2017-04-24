local fns = require 'handle_category_print'
local file = require 'pl.file'
local print_csv = require 'print_csv'

local test_input_dir = "./test_data/"
local print_out_dir = "./test_print_data/print_tmp/"

-- command setting which needs to be done for all test-cases
dir.makepath("./test_print_data/print_tmp/")
--set environment variables for test-case (LOAD CSV) 
_G["Q_DATA_DIR"] = "./test_data/out/"
_G["Q_META_DATA_DIR"] = "./test_data/metadata/"
_G["Q_DICTIONARIES"] = {}

dir.makepath(_G["Q_DATA_DIR"])
dir.makepath(_G["Q_META_DATA_DIR"])


-- Test Case Start ---------------
local T = dofile("map_metadata_data.lua")
for i, v in ipairs(T) do
  
  if arg[1] and i ~= tonumber(arg[1]) then 
    goto skip 
  end
  
  local M = dofile("./test_metadata/"..v.meta)

  local D = v.data
  local F = v.filter
  local csv_file = v.csv_file
  print("----------------------------------------")
  if v.category == "category6" then
    local key = "handle_"..v.category
    fns[key](i, v, M)
    goto skip
  end
  local status, load_ret = pcall(load_csv,"./test_data/"..D, M)
  if status then
    -- if handle_input_function is present, then filter is taken from the output of this function
    -- in other cases , filter object is taken from metadata
    local key = "handle_input_"..v.category
    if fns[key] then
      F = fns[key]()
    end
    local status, print_ret = pcall(print_csv, load_ret, F, print_out_dir..csv_file)
    key = "handle_"..v.category
    if fns[key] then
      fns[key](i, v,  print_out_dir..csv_file, print_ret, status)
    end
    
  else
    --print(" testcase failed: load api failed in print testcase. this should not happen")
    fns["increment_failed"](i, v, " testcase failed: load api failed in print testcase. this should not happen")
  end
  ::skip::
end

fns["print_result"]()


--command cleanup for all testcases
--dir.rmtree(_G["Q_DATA_DIR"])
--dir.rmtree(_G["Q_META_DATA_DIR"])
--dir.rmtree("./test_data/print_tmp/")