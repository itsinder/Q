os.execute("rm -f _*.bin")
local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local buf = cmem.new(4096)
-- for k, v in pairs(vec) do print(k, v) end 

local y = Vector.new('I4', 'in1.bin', nil, false)
y:persist(true)
print(Vector.length(y))
print(y:length())
print(y:check())
print("xxxxxxxxxxxxx")
local a, b = y:eov()
assert(a == nil)
local i, j = string.find(b, "ERROR")
assert(i >= 0)
local M = load(y:meta())()
print(M)
for k, v in pairs(M) do print(k, v) end
print('------------------')
y = nil
collectgarbage()
assert(plpath.isfile("in1.bin"))

-- create a nascent vector
y = Vector.new('I4')
local num_elements = 16*1048576
for j = 1, num_elements do 
  local s1 = Scalar.new(j, "I4")
  y:append(s1)
end
local M
print("writing meta data of nascent vector")
M = load(y:meta())(); for k, v in pairs(M) do print(k, v) end
y:eov()
print("writing meta data of persisted vector")
M = load(y:meta())(); for k, v in pairs(M) do print(k, v) end
y:persist()
assert(y:check())
--================================
y = Vector.new('I4', M.file_name)
print("writing meta data of new vector from old file name ")
M = load(y:meta())(); for k, v in pairs(M) do print(k, v) end
assert(y:check())
print("here is where strangeness happens >>>>>> ")

local S = {}
for j = 1, num_elements do
  -- S[j] = Scalar.new(j*10, "I4")
  s = Scalar.new(j*10, "I4")
  status = y:set(s, j-1)
  assert(status)
  status = y:set(j*10, j-1)
  assert(status)
  assert(y:check())
end

y:persist()
assert(y:check())
local M = load(y:meta())()
print("Persisting ", M.file_name)
-- TODO Why does this not work? assert(plpath.isfile(M.file_name))
print("Completed ", arg[0])
os.exit()

--======================
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
y:meta()

--=========================
print("Completed ", arg[0])
