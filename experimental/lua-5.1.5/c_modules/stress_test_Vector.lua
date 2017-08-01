local plfile = require 'pl.file'
local plpath = require 'pl.path'
local Vector = require 'libvec'  
local Scalar = require 'libsclr'  
local cmem = require 'libcmem'  
local lVector = require 'lVector'
-- local dbg    = require 'Q/UTILS/lua/debugger'
local ffi    = require 'Q/UTILS/lua/q_ffi'
require 'Q/UTILS/lua/strict'
--
num_iters = 1024
for i = 1, num_iters do
  local x = lVector( { qtype = "I4", gen = true})
  num_elements = 1048576+3
  field_size = 4
  base_data = cmem.new(num_elements * field_size)
  iptr = ffi.cast("int32_t *", base_data)
  for i = 1, num_elements do
    local s1 = Scalar.new(i*11, "I4")
    local s2
    if ( ( i % 2 ) == 0 ) then
      s2 = Scalar.new(true, "B1")
    else
      s2 = Scalar.new(false, "B1")
    end
    x:put1(s1, s2)
  end
  x:eov()
  local T = x:meta()
  assert(plpath.isfile(T.base.file_name))
  print("Iter = ", i)
end
print("Completed ", arg[0])
os.exit()
