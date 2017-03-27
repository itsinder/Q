local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/DATA_LOAD/lua/?.lua"

require 'load_csv'
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
function handle_output(status, ret, v)
  local output
  if v.output_regex ~= nil then
    output = v.output_regex
  end
  --print(v.meta)
  -- if status not true, then check output error with the expected error.
  -- if match then testcase success, else fail
  --print(ret)
  if ( not status ) then 
    if output == nil then
      print("load API failed, but output_regex is null")
      number_of_testcases_failed = number_of_testcases_failed + 1
      return
    end
    -- get the actual error message from the ret
    local a, b, err = plstring.splitv(ret,':')
    err = plstring.strip(err) -- check it can be used  from utils.
    -- trimming whitespace
     
    local error_msg = plstring.strip(output) -- check it can be used from utils.
    
    print("actual error:"..err)
    print("expected error:"..error_msg)
    -- check this line can be skipped with the duplicate line below
    if error_msg == err then
      number_of_testcases_passed = number_of_testcases_passed + 1 
    else
      number_of_testcases_failed = number_of_testcases_failed + 1
      print(v.data)
    end
  else
  -- if status is true, then check the type of output.
  -- if it is a table, then testcase successful, else fail
    if type(ret) == "table" then
      number_of_testcases_passed = number_of_testcases_passed + 1
    else
      number_of_testcases_failed = number_of_testcases_failed + 1
    end
    print("tested success for "..v.data)
  end
end

-- Test Case Start ---------------
local T = dofile("map_metadata_data.lua")
for i, v in ipairs(T) do
  _G["Q_DICTIONARIES"] = {}
  print("--------------------------------")
  local M = dofile(test_metadata_dir..v.meta)
  local D = v.data
  local status, ret = pcall(load_csv,test_input_dir..D,  M)
  handle_output(status, ret, v)
end



print("-----------------------------------")
print("No of successfull testcases ",number_of_testcases_passed)
print("No of failure testcases     ",number_of_testcases_failed)
print("-----------------------------------")

-- common cleanup (TEAR DOWN) for all testcases
-- clear the output directory 
dir.rmtree(_G["Q_DATA_DIR"])
dir.rmtree(_G["Q_META_DATA_DIR"])
