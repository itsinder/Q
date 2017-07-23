vec = require 'libvec' ; 
cmem = require 'libcmem' ; 

local num_trials = 1048576 -- 1024*1048576
local sz = 65537
for j = 1, num_trials do 
  local buf = cmem.new(sz)
  buf = nil
  collectgarbage()
end
print("Completed ", arg[0])
