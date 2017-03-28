local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/DATA_LOAD/lua/?.lua"

require 'load_csv'
require 'C_to_txt'
local plstring = require 'pl.stringx'
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

local number_of_testcases_passed = 0
local number_of_testcases_failed = 0

local
function handle_output_regex(status, v, flag)
  local output
  if flag then status = status else status = not status end
  -- in category 1 , status = status , flag = true . if status is true, testcase should fail
  -- in category 2,  status = not status, flag = false, if status is false, testcase should fail
  if status then
    print("testcase failed , incorrect status value")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  -- output_regex should be present in map_metadata, 
  -- else testcase should fail
  if v.output_regex == nil then
    print("testcase failed , incorrect output regex value")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end  
  
  output = v.output_regex
  return output
end
  
local 
function handle_category1(status, ret, v)
  print(v.meta)
  local output = handle_output_regex(status, v, true)
  if output == nil then return end
  
  -- ret is of format <filepath>:<line_number>:<error_msg>
  -- get the actual error message from the ret
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  
  -- trimming whitespace
  local error_msg = plstring.strip(output) -- check it can be used from utils.
  
  print("actual output:"..err)
  print("expected output:"..error_msg)
  -- check this line can be skipped with the duplicate line below
  if error_msg == err then
    number_of_testcases_passed = number_of_testcases_passed + 1 
  else
    print("testcase category1 failed , actual and expected error message does not match")
    number_of_testcases_failed = number_of_testcases_failed + 1
  end
end

  
local 
function handle_category2(status, ret, v)
  print(v.meta)
  local output = handle_output_regex(status, v, false)
  
  if type(ret) ~= "table" or type(output) ~= "table" then
    print("testcase category2 failed , output of load or output regex is not a table")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  if type(ret[1]) ~= "Column" then
    print("testcase category2 failed , output of load is not a column")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  --print(ret[1]:length())
  --print(#output)
  if ret[1]:length() ~= #output then
    print("testcase category2 failed , length of output of load and output regex does not match")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  for i=1,#output do
    convert_c_to_txt(ret[1],i)
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1 
  
end


-- loop through category1 testcases
-- these testcases output error messages
local T = dofile("map_metadata_data.lua")
for i, v in ipairs(T.category1) do
  _G["Q_DICTIONARIES"] = {}
  print("--------------------------------")
  local M = dofile(test_metadata_dir..v.meta)
  local D = v.data
  local status, ret = pcall(load_csv,test_input_dir..D,  M)
  handle_category1(status, ret, v)
end

for i, v in ipairs(T.category2) do
  _G["Q_DICTIONARIES"] = {}
  print("--------------------------------")
  local M = dofile(test_metadata_dir..v.meta)
  local D = v.data
  local status, ret = pcall(load_csv,test_input_dir..D,  M)
  handle_category2(status, ret, v)
end




print("-----------------------------------")
print("No of successfull testcases ",number_of_testcases_passed)
print("No of failure testcases     ",number_of_testcases_failed)
print("-----------------------------------")

-- common cleanup (TEAR DOWN) for all testcases
-- clear the output directory 
dir.rmtree(_G["Q_DATA_DIR"])
dir.rmtree(_G["Q_META_DATA_DIR"])
