local Scalar	= require 'libsclr'
local lVector	= require 'Q/RUNTIME/lua/lVector'
local cmem	= require 'libcmem'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'

local tests = {}
--====== Testing vector cloning
tests.t1 = function()
  print("Creating vector")
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 1024
  local field_size = 4
  local c = cmem.new(num_elements * field_size, "I4")
  local iptr = assert(get_ptr(c, "I4"))
  for i = 1, num_elements do
    iptr[i-1] = i*10
  end
  x:put_chunk(c, nil, num_elements)
  x:eov()
  x:persist(true)
  
  -- set metadata
  x:set_meta("key1", "val1")

  print("Cloning vector")
  local x_clone = x:clone()
  assert(x_clone:num_elements() == num_elements)

  x_meta = x:meta()
  x_clone_meta = x_clone:meta()

  -- persist flag should be false
  assert(x_clone_meta.base.is_persist == false)

  -- OPEN_MODE should be zero
  assert(x_clone_meta.base.open_mode == "NOT_OPEN")

  -- compare base metadata
  for i, v in pairs(x_meta.base) do
    if not ( i == "file_name" or i == "open_mode" or i == "is_persist" ) then
      assert(v == x_clone_meta.base[i])
    end
  end

  -- compare aux metadata
  for i, v in pairs(x_meta.aux) do
    print(i, v)
    assert(v == x_clone_meta.aux[i])
  end

  -- compare vector elements
  for i = 1, x_clone:num_elements() do
    val, nn_val = x_clone:get_one(i-1)
    assert(val)
    assert(type(val) == "Scalar")
    assert(val == Scalar.new(i*10, "I4"))
  end

  print("Successfully completed test t1")
end

return tests
