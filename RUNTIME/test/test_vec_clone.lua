local lVector	= require 'Q/RUNTIME/lua/lVector'
local cmem	= require 'libcmem'
local ffi	= require 'Q/UTILS/lua/q_ffi'
local c_to_txt	= require 'Q/UTILS/lua/C_to_txt'
local Scalar	= require 'libsclr'
local plpath  = require 'pl.path'
local genbin = require 'Q/RUNTIME/test/generate_bin'

local script_dir = os.getenv("Q_SRC_ROOT") .. "/RUNTIME/test/"
assert(plpath.isdir(script_dir))


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
    assert(v == x_clone_meta.aux[i])
  end

  -- compare vector elements
  local val, nn_val
  for i = 1, x_clone:num_elements() do
    val, nn_val = c_to_txt(x_clone, i)
    assert(val == i*10)
  end

  print("Successfully completed test t1")
end

tests.t2 = function()
  print("Creating nascent vector")
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local num_elements = 100
  local field_size = 4
  for i = 1, num_elements do
    local s1 = Scalar.new(i, "I4")
    x:put1(s1)
    assert(x:check())
  end

  -- set metadata
  x:set_meta("key1", "val1")

  print("Cloning non_eov vector")
  local x_clone = x:clone()
  assert(x_clone:num_elements() == num_elements)
  
  x_meta = x:meta()
  x_clone_meta = x_clone:meta()

  -- persist flag should be false
  assert(x_clone_meta.base.is_persist == false)

  -- is_eov flag should be false
  assert(x_clone_meta.base.is_eov == false)

  -- compare base metadata
  for i, v in pairs(x_meta.base) do
    if not ( i == "file_name" or i == "open_mode" or i == "is_persist" ) then
      assert(v == x_clone_meta.base[i])
    end
  end

  -- compare aux metadata
  for i, v in pairs(x_meta.aux) do
    assert(v == x_clone_meta.aux[i])
  end

  -- compare vector elements
  local val, nn_val
  for i = 1, x_clone:num_elements() do
    val, nn_val = c_to_txt(x_clone, i)
    assert(val == i)
  end

  -- Add elements to cloned vector
  for i = 1, num_elements do
    local s1 = Scalar.new(i*2, "I4")
    x_clone:put1(s1)
  end
  
  -- Perform EOV
  x:eov()
  x_clone:eov()

  -- Validations
  assert(x:length() == num_elements)
  assert(x_clone:length() == num_elements * 2)

  local count = 1

  -- Validate x_clone values
  for i = 101, 200 do
    val, nn_val = c_to_txt(x_clone, i)
    assert(val == count*2)
    count = count + 1
  end
  print("Successfully completed test t2")
end

tests.t3 = function()
  print("Creating materialized vector with nn")
  local num_values = 10
  local q_type = "I4"

  -- generating .bin files required for materialized vector
  qc.generate_bin(num_values, q_type, script_dir .. "_in1_I4.bin", "linear" )
  q_type = "B1"
  genbin.generate_bin(num_values, q_type, script_dir .. "_nn_in1.bin")

  local x = lVector(
  { qtype = "I4", file_name = script_dir .. "_in1_I4.bin", nn_file_name = script_dir .. "_nn_in1.bin"})

  print("Cloning vector")
  local x_clone = x:clone()
  assert(x_clone:num_elements() == num_values)

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

  -- compare nn metadata
  --for i, v in pairs(x_meta.nn) do
  --  if not ( i == "file_name" or i == "open_mode" or i == "is_persist" ) then 
  --    assert(v == x_clone_meta.nn[i])
  --  end
  --end

  -- compare vector elements
  local Q = require 'Q'
  local val, nn_val, clone_val, clone_nn_val
  for i = 1, x_clone:num_elements() do
    val, nn_val = c_to_txt(x, i)
    clone_val, clone_nn_val = c_to_txt(x_clone, i)
    assert(val == clone_val)
    assert(nn_val == clone_nn_val)
  end

  print("Successfully completed test t3")
end

return tests
