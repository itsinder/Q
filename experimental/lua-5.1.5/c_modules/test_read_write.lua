--os.execute("rm -f _*.bin")
local plpath = require 'pl.path'
local Vector = require 'libvec' ;
local ffi = require 'Q/UTILS/lua/q_ffi'
local num_elements = 10

y = Vector.new('I4')
print("writing meta data of new vector ")
print("================================================")
M = loadstring(y:meta())(); for k, v in pairs(M) do print(k, v) end
print("================================================")
assert(y:check())

local S = {}
for j = 1, num_elements do
  status = y:set(j*10, j-1)
  assert(status)
  assert(y:check())
end

ret_addr, ret_len, ret_val  = y:get(0, 2)
print(ret_len)
assert(ret_addr)
--assert(ret_len == 2)

local str = ffi.cast("int32_t *", ret_addr)
for i=0, ret_len-1 do
  print(str[i])
end

y:eov()
assert(y:check())
local M = loadstring(y:meta())()
--assert(plpath.isfile(M.file_name))
os.exit()
