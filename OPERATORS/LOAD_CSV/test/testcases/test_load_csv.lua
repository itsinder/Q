local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
--package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
--package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"
--package.path = package.path.. ";" .. rootdir .. "/OPERATORS/LOAD_CSV/lua/?.lua"

require 'load_csv'
require 'handle_category'

--local Dictionary = require 'dictionary'

local test_input_dir = "./test_data/"
local test_metadata_dir ="./test_metadata/"
-- common setting (SET UPS) which needs to be done for all test-cases
--set environment variables for test-case
_G["Q_DATA_DIR"] = "./test_data/out/"
_G["Q_META_DATA_DIR"] = "./test_data/metadata/"
_G["Q_DICTIONARIES"] = {}
dir.makepath(_G["Q_DATA_DIR"])
dir.makepath(_G["Q_META_DATA_DIR"])


local handle_function = {}
-- handle error message testcases
handle_function["category1"] = handle_category1
-- handle 1D output regex.
handle_function["category2"] = handle_category2
-- handle 2D output_regex
handle_function["category3"] = handle_category3
-- handle length of bin files in this testcase
handle_function["category4"] = handle_category4
-- handle null file deletion testcase
handle_function["category5"] = handle_category5
-- handle environment test cases
handle_function["category6"] = handle_category6

-- loop through testcases
-- these testcases output error messages
local T = dofile("map_metadata_data.lua")
for i, v in ipairs(T) do
  if arg[1] and i ~= tonumber(arg[1]) then 
    goto skip 
  end
  
  _G["Q_DICTIONARIES"] = {}
  _G["Q_DATA_DIR"] = "./test_data/out/"
  _G["Q_META_DATA_DIR"] = "./test_data/metadata/"
  print("--------------------------------")
  local M = dofile(test_metadata_dir..v.meta)
  local D = v.data
  -- if category6 then set environment in handle_input_category6 function
  if v.category == "category6" then
    --print(v.input_regex)
    handle_input_category6(v.input_regex)
  end
  
  local status, ret = pcall(load_csv,test_input_dir..D,  M)
  --local status, ret = load_csv(test_input_dir..D,  M)
  if handle_function[v.category] then
    --print (handle_function[v.category])
    handle_function[v.category](i, status, ret, v)
  end
  ::skip::
end

print_result()

_G["Q_DATA_DIR"] = "./test_data/out/"
_G["Q_META_DATA_DIR"] = "./test_data/metadata/"
-- common cleanup (TEAR DOWN) for all testcases
-- clear the output directory 
--dir.rmtree(_G["Q_DATA_DIR"])
--dir.rmtree(_G["Q_META_DATA_DIR"])
