local plpath = require 'pl.path'
Vector = require 'libvec' ; 
Scalar = require 'libsclr' ; 
cmem = require 'libcmem' ; 
local buf = cmem.new(4096)
-- for k, v in pairs(vec) do print(k, v) end 

s1 = Scalar.new(123, "I4")
y = Vector.new('I4', 'in1.bin', nil, false)
y:persist(true)
print(Vector.length(y))
print(y:length())
print(y:check())
print("xxxxxxxxxxxxx")
a, b = y:eov()
assert(a == nil)
i, j = string.find(b, "ERROR")
assert(i >= 0)
M = load(y:meta())()
print(M)
for k, v in pairs(M) do print(k, v) end
print('------------------')
y = nil
collectgarbage()
assert(plpath.isfile("in1.bin"))

local num_trials = 65536
for j = 1, num_trials do 
  y = Vector.new('I4', 'in1.bin')
  assert(type(y) == "userdata")
  y:persist()
  --[[
  for i = 1, num_elements do
    status = y:set(buf, i-1, 1)
    assert(status == 0)
    ret_addr, ret_len, ret_val  = Vector.get(y, i-1, 1)
    -- print("addr ", ret_addr); print("len ", ret_len)
    assert(ret_addr)
    -- print(ret_addr, ret_len, ret_val)
    assert(ret_len == 1)
  end
  --]]
  print("Iter ", j)
end

--=========================
print("Completed ", arg[0])
