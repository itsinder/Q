local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/DATA_LOAD/lua/?.lua"

require("validate_meta")
require("error_code")

local T = dofile("meta_data.lua")

for i, gm in ipairs(T) do
  print("Testing " .. gm)
  M = dofile("test_metadata/"..gm)
  status, err = pcall(validate_meta, M)
  
  if ( not status ) then 
    print("Error:", err)
  end
  
end