local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/DATA_LOAD/lua/?.lua"

require("validate_meta")

local no_of_success = 0
local no_of_failure = 0
local T = dofile("meta_data.lua")
for i, m in ipairs(T) do
  
  M = dofile("test_metadata/"..m)
  status, err = pcall(validate_meta, M)
  if ( not status ) then 
    print(i,"Testing " .. m)
    print("Error:", err)
    no_of_failure = no_of_failure + 1
  else
    print(i,"Testing success   " .. m )
    no_of_success = no_of_success + 1
  end
end
print("-----------------------------------")
print("No of successfull testcases ",no_of_success)
print("No of failure testcases     ",no_of_failure)
print("-----------------------------------")

