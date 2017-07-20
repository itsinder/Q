vec = require 'libtest' ; 
cmem = require 'libcmem' ; 
local buf = cmem.new(4096)
-- for k, v in pairs(vec) do print(k, v) end 

local num_trials = 1024
local num_elements = 1048576+17
for j = 1, num_trials do 
  y = vec.new('I4', 4, 32); 
  status = vec.nascent(y);
  assert(status == 0)
  for i = 1, num_elements do
    status = vec.set(y, buf, i-1, 1)
    assert(status == 0)
    ret_addr, ret_len, ret_val  = vec.get(y, i-1, 1)
    -- print("addr ", ret_addr); print("len ", ret_len)
    assert(ret_addr)
    -- print(ret_addr, ret_len, ret_val)
    assert(ret_len == 1)
  end
  print("Iter ", j)
end

--=========================
z = vec.new('F8', 8, 65536); 
status = vec.nascent(z);
z = nil
print("Completed ", arg[0])
