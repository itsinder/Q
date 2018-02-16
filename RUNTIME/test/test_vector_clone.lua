local lVector	= require 'Q/RUNTIME/lua/lVector'
local cmem	= require 'libcmem'
local ffi	= require 'Q/UTILS/lua/q_ffi'

local tests = {}
--====== Testing vector cloning
tests.t1 = function()
  print("Creating vector")
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 1024
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, num_elements do
    iptr[i-1] = i*10
  end
  x:put_chunk(base_data, nil, num_elements)
  x:eov()

  print("Cloning vector")
  local x_clone = x:clone()
  assert(x_clone:num_elements() == num_elements)
  x_meta = x:meta()
  x_clone_meta = x_clone:meta()

  -- compare base metadata
  for i, v in pairs(x_meta.base) do
    if i ~= "file_name" then
      assert(v == x_clone_meta.base[i])
    else
      assert(v ~= x_clone_meta.base[i])
    end
  end
  print("Successfully completed test t1")
end

return tests
