vec = require 'libvec' ; 
cmem = require 'libcmem' ; 

local num_trials = 1024*1048576
local num_elements = 65537
for j = 1, num_trials do 
  local buf = cmem.new(4096)
  buf = nil
  collectgarbage()
end
print("Completed ", arg[0])
