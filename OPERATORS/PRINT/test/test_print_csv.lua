local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")

package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/DATA_LOAD/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/PRINT/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"

local file = require 'pl.file'
local plstring = require 'pl.stringx'
local Vector = require 'Vector'
require 'load_csv'
require 'print_csv'

local number_of_testcases_passed = 0
local number_of_testcases_failed = 0

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



function handle_category1(v, csv_file,ret, status)
  print(v.meta) 
  --print(status)
  if not status then
    print("in category1, status should be true")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  local actual_file_content = file.read("test_data/"..v.data)
  local expected_file_content = file.read(csv_file)
  print(actual_file_content)
  print(expected_file_content)
  if actual_file_content ~= expected_file_content then
     print("input and output csv file does not match")
     number_of_testcases_failed = number_of_testcases_failed + 1
     return nil
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
end

function handle_category2(v, csv_file, ret, status)
  print(v.name) 
  
  if status or v.output_regex==nil then
    print("in category2, status should be false")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  local actual_output = ret
  local expected_output = v.output_regex
  
  local a, b, err = plstring.splitv(actual_output,':')
  err = plstring.strip(err) 
  print("Actual error:"..err)
  print("Expected error:"..expected_output)
  if err ~= expected_output then
     print("actual and expected error does  not match")
     number_of_testcases_failed = number_of_testcases_failed + 1
     return nil
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
end


function handle_input_category4()
  local v1 = Vector{field_type='I4', field_size = 1/8,chunk_size = 8,
    filename="./bin/I4.bin",  
  }
  return { where = v1 }
end

function handle_category4(v, csv_file, ret, status)
  print(v.name) 
  
  if status then
    print("in category4, status should be true")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  local expected_output = v.output_regex
   
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  print("Actual error:"..err)
  print("Expected error:"..expected_output)
  
  if err ~= expected_output then
     print("in category 4, actual and expected error does  not match")
     number_of_testcases_failed = number_of_testcases_failed + 1
     return nil
  end
   number_of_testcases_passed = number_of_testcases_passed + 1
end

local handle_function = {}
-- input and output csv file match testcases
handle_function["category1"] = handle_category1
-- filter testcases
handle_function["category2"] = handle_category2
-- filter type is vector 
handle_function["category3"] = handle_category3
-- filter type is vector 
handle_function["category4"] = handle_category4

local handle_input_function = {}
-- input and output csv file match testcases
--handle_input_function["category3"] = handle_input_category3
-- filter testcases
handle_input_function["category4"] = handle_input_category4


-- Test Case Start ---------------
local T = dofile("map_metadata_data.lua")
for i, v in ipairs(T) do
  local M = dofile("./test_metadata/"..v.meta)

  local D = v.data
  local F = v.filter
  local csv_file = v.csv_file
  print("----------------------------------------")
  local status, load_ret = pcall(load_csv,"./test_data/"..D, M)
  if status then
    if handle_input_function[v.category] then
      F = handle_input_function[v.category]()
    end
    local status, print_ret = pcall(print_csv, load_ret, F, print_out_dir..csv_file)
    if handle_function[v.category] then
      handle_function[v.category](v,  print_out_dir..csv_file, print_ret, status)
    end
    
  else
    
  end
end

print("-----------------------------------")
print("No of successfull testcases ",number_of_testcases_passed)
print("No of failure testcases     ",number_of_testcases_failed)
print("-----------------------------------")



--command cleanup for all testcases
--dir.rmtree(_G["Q_DATA_DIR"])
--dir.rmtree(_G["Q_META_DATA_DIR"])
--dir.rmtree("./test_data/print_tmp/")