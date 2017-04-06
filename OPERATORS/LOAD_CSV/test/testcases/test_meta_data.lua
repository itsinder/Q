local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/LOAD_CSV/lua/?.lua"

local plstring = require 'pl.stringx'
require("validate_meta")
_G["Q_META_DATA_DIR"] = "./metadata"
local no_of_success = 0
local no_of_failure = 0
local T = dofile("meta_data.lua")
local failed_testcases = {}

for i, m in ipairs(T) do
  
  if arg[1]~= nil and tonumber(arg[1])~=i then goto skip end
  print(i,"Testing " .. m.meta)
  local M = dofile("test_metadata/"..m.meta)
  local status, ret = pcall(validate_meta, M)
  --local status, ret = validate_meta(M)
  if ( not status ) then 
    if m.output_regex == nil then
      no_of_failure = no_of_failure + 1
      table.insert(failed_testcases,i)
    else
      -- ret contain string in the format <filepath>:<line_num>:<error_msg>
      -- below line extract error_msge from ret and put in err variable
      local a, b, err= plstring.splitv(ret,':')
      -- trim whitespace required below, as splitv returned string with whitespace
      err = plstring.strip(err)
      
      -- output_regex contain the error message expected returned by validate_metadata
      local error_msg = m.output_regex 
      print("actual error", err)
      print("expected error", error_msg)
      -- match actual error msg with expected error msg
      if err == error_msg then
        no_of_success = no_of_success + 1
      else
        no_of_failure = no_of_failure + 1
        table.insert(failed_testcases,i)
      end
    end
  else
    --print(i,"Testing success   " .. m.meta)
    if m.output_regex then
      no_of_failure = no_of_failure + 1
      table.insert(failed_testcases,i)
    else
      no_of_success = no_of_success + 1
    end
  end
  ::skip::
end
print("-----------------------------------")
print("No of successfull testcases ",no_of_success)
print("No of failure testcases     ",no_of_failure)
print("-----------------------------------")

if #failed_testcases > 0 then
  print("---run bash test_meta_data.sh <testcase_number> for more details -------")
  print("---Testcases failed are -------")
end

for i=1,#failed_testcases do
  print(failed_testcases[i])
end


