cmem = require 'libcmem' ; 

local num_trials = 10 -- 1024*1048576
local sz = 65537
for j = 1, num_trials do 
  local buf = cmem.new(sz)
  buf:set(j, "I4") -- for debugging
  -- print(buf, "I4")
  x = buf:print("I4")
  assert(j == tonumber(x))
  print(j, x)
  buf = nil
end
local num_elements = 1024
local buf = cmem.new(num_elements * 4)
local start = 123
local incr  = 1
buf:seq(start, incr, num_elements, "I4")
x = buf:print("I4")
assert(start == tonumber(x))

print("Completed ", arg[0])
