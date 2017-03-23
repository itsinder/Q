local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
--package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/DATA_LOAD/lua/?.lua"

require("globals")
require("validate_meta")

--_G["Q_META_DATA_DIR"] = "/tmp/" 
local T = dofile("meta_data.lua")
for i, m in ipairs(T) do
  print(i,"Testing " .. m)
  M = dofile("test_metadata/"..m)
  status, err = pcall(validate_meta, M)
  --print("status:",status)
  if ( not status ) then 
    print("Error:", err)
  end
end