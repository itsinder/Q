local plfile = require 'pl.file'
local plpath = require 'pl.path'
local Vector = require 'libvec'  
local Scalar = require 'libsclr'  
local cmem = require 'libcmem'  
local lVector = require 'lVector'
-- local dbg    = require 'Q/UTILS/lua/debugger'
local ffi    = require 'Q/UTILS/lua/q_ffi'
require 'Q/UTILS/lua/strict'
local v
local ival
local databuf
--===================
function pr_meta(x, file_name)
  local T = x:meta()
  io.output(file_name)
  for k1, v1 in pairs(T) do 
    for k2, v2 in pairs(v1) do 
      io.write(k1 .. ":" ..  k2 .. " => " .. tostring(v2))
      io.write("\n")
    end
  end
  io.close()
end
--=========================
function compare(f1, f2)
  local s1 = plfile.read(f1)
  local s2 = plfile.read(f2)
  assert(s1 == s2)
end
--=========================
--
local x = lVector(
{ qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin"})
assert(x:check())
pr_meta(x, "_meta_data.csv")
compare("_meta_data.csv", "in1_meta_data.csv")
base_data, nn_data, len = x:get_chunk()
assert(base_data)
assert(nn_data)
assert(len == 10)
--=========

x = lVector( { qtype = "I4", file_name = "_in2_I4.bin"})
assert(x:check())
n = x:num_elements()
assert(n == 10)
--=========
base_data, nn_data, len = x:get_chunk()
assert(base_data)
iptr = ffi.cast("int32_t *", base_data)
for i = 1, len do
  assert(iptr[i-1] == (i*10))
end
assert(not nn_data)
assert(len == 10)
--=========
base_data, nn_data, len = x:get_chunk(100)
assert(not base_data)
assert(not nn_data)
--=========

x:set_meta("rand key", "rand val")
v = x:get_meta("rand key")
assert(v == "rand val")
x:set_meta("rand key", "some other rand val")
v = x:get_meta("rand key")
assert(v == "some other rand val")
pr_meta(x, "_meta_data.csv")
compare("_meta_data.csv", "in2_meta_data.csv")

--====== Testing nascent vector
local x = lVector( { qtype = "I4", gen = true})
num_elements = 1024
field_size = 4
base_data = cmem.new(num_elements * field_size)
iptr = ffi.cast("int32_t *", base_data)
for i = 1, num_elements do
  iptr[i-1] = i*10
end
x:put_chunk(base_data, nil, num_elements)
x:eov()
pr_meta(x, "_xxx")
--
--====== Testing nascent vector with scalars
local x = lVector( { qtype = "I4", gen = true})
num_elements = 1024
field_size = 4
base_data = cmem.new(num_elements * field_size)
iptr = ffi.cast("int32_t *", base_data)
for i = 1, num_elements do
  local s1 = Scalar.new(i*11, "I4")
  x:put1(s1)
end
x:eov()
pr_meta(x, "_yyy")


print("Completed ", arg[0])
os.exit()
