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

-- try to modify a vector created as read only. Should fail
local is_read_only = true
local y = Vector.new('I4', 'in1.bin', nil, is_read_only)
y:persist(true)
s = Scalar.new(123, "I4")
status = y:set(s, 0)
assert(status == nil)
--==============================================
-- try to modify a vector created as read only by eov. Should fail
local is_read_only = true
local y = Vector.new('I4')
status = y:append(s)
y:eov(true)
status = y:set(s, 0)
assert(status == nil)
--==============================================
-- can memo a vector until it hits chunk size. then must fail
local y = Vector.new('I4')
local is_memo
local chunk_size = 65536  
for i = 1, chunk_size do 
  status = y:append(s)
  if ( ( i % 2 ) == 0 ) then is_memo = true else is_memo = false end
  status = y:memo(is_memo)
  assert(status)
end
status = y:append(s)
status = y:memo(is_memo)
assert(status == nil)
local M
--==============================================
-- num_in_chunk should increase steadily and then reset after chunk_sizr
local y = Vector.new('I4')
local is_memo
local chunk_size = 65536  
for i = 1, chunk_size do 
  status = y:append(s)
  assert(status)
  M = load(y:meta())(); 
  assert(M.num_in_chunk == i)
  assert(M.chunk_num == 0)
end
status = y:append(s)
M = load(y:meta())(); 
assert(M.num_in_chunk == 1)
assert(M.chunk_num == 1)
status = y:memo(is_memo)
assert(status == nil)
--==============================================
print("DONE")
os.exit()

-- create a nascent vector
y = Vector.new('I4')
local num_elements = 100000000
for j = 1, num_elements do 
  local s1 = Scalar.new(j, "I4")
  y:append(s1)
end
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
  ret_addr, ret_len, ret_val  = y:get(j-1, 1)
  assert(ret_addr)
  assert(ret_len == 1)
  assert(Scalar.to_str(ret_val) == tostring(j*10))
end

y:persist()
assert(y:check())
local M = load(y:meta())()
print("Persisting ", M.file_name)
assert(plpath.isfile(M.file_name))
--=========================
print("Completed ", arg[0])
os.exit()
