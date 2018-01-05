local Vector  = require 'libvec'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'

local tests = {} 

-- Create nascent vector with num_elements less than q_chunk_size
tests.t1 = function()
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, num_elements do
    iptr[i-1] = i*10
  end
  x:put_chunk(base_data, nil, num_elements)
  assert(x:check())

  -- Call EOV
  x:eov()
  assert(x:check())

  -- Call chunk() method without parameter,
  -- it should be serverd from buffer not from file

  local len, base, nn = x:get_all()
  assert(base)
  assert(len == 1024)

  local T = x:meta()
  assert(T.base.is_nascent == true)
  assert(T.base.open_mode == "NOT_OPEN")

  print("Successfully completed test t1")
end
-- =========

return tests
