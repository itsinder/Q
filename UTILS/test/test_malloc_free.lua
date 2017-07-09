-- FUNCTIONAL
-- This tests whether garbage collection is happening as expected
-- If it were not, this would/should blow through your system's memory
local ffi = require 'Q/UTILS/lua/q_ffi'

for iter = 1, 4096 do 
  local X = {}
  for i = 1, 4096 do 
    X[i] = ffi.malloc(4096)
  end
  local n = collectgarbage("count")
  -- print(" Iter/n ", iter, n)
end
local n = collectgarbage("collect")
assert(n == 0)

print("SUCCESS for ", arg[0])
