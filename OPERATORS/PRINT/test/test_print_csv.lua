local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")

--package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
--package.path = package.path.. ";" .. rootdir .. "/OPERATORS/LOAD_CSV/lua/?.lua"
--package.path = package.path.. ";" .. rootdir .. "/OPERATORS/PRINT/lua/?.lua"
--package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"

require 'handle_category_print'
local file = require 'pl.file'

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


local handle_function = {}
-- input and output csv file match testcases
handle_function["category1"] = handle_category1
-- invalid filter testcases
handle_function["category2"] = handle_category2
-- filter type is vector B1 
handle_function["category3"] = handle_category3
-- filter type is vector I4
handle_function["category4"] = handle_category4
-- valid range filter
handle_function["category5"] = handle_category5
-- csv consumable testcase
handle_function["category6"] = handle_category6

local handle_input_function = {}
-- input vector returned is B1
handle_input_function["category3"] = handle_input_category3
-- input vector retured is I4
handle_input_function["category4"] = handle_input_category4


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
    handle_category6(i, v, M)
    goto skip
  end
  local status, load_ret = pcall(load_csv,"./test_data/"..D, M)
  if status then
    -- if handle_input_function is present, then filter is taken from the output of this function
    -- in other cases , filter object is taken from metadata
    if handle_input_function[v.category] then
      F = handle_input_function[v.category]()
    end
    local status, print_ret = pcall(print_csv, load_ret, F, print_out_dir..csv_file)
    if handle_function[v.category] then
      handle_function[v.category](i, v,  print_out_dir..csv_file, print_ret, status)
    end
    
  else
    --print(" testcase failed: load api failed in print testcase. this should not happen")
    increment_failed(i, v, " testcase failed: load api failed in print testcase. this should not happen")
  end
  ::skip::
end

print_testcases_result()


--command cleanup for all testcases
--dir.rmtree(_G["Q_DATA_DIR"])
--dir.rmtree(_G["Q_META_DATA_DIR"])
--dir.rmtree("./test_data/print_tmp/")