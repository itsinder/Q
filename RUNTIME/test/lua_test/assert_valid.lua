local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local dbg    = require 'Q/UTILS/lua/debugger'
local vec_utils = require 'Q/RUNTIME/test/lua_test/vec_utility'
local Scalar  = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem    = require 'libcmem'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local fns = {}

--===================

local set_value = function(buffer, index, value)
  buffer[index] = value
end

--===================
local validate_vec_meta = function(meta, is_materialized, num_elements)
  local status = true
  if is_materialized then
    assert(meta.is_nascent == false)
    assert(meta.file_name)
    assert(plpath.exists(meta.file_name))
  else
    assert(meta.is_nascent == true)
  end
  
  if num_elements and not is_materialized then
    assert(meta.chunk_num == math.floor(num_elements / qconsts.chunk_size))
    assert(meta.num_in_chunk == num_elements % qconsts.chunk_size)
    assert(meta.num_elements == num_elements)
  end
  return status
end


local nascent_vec_basic_operations = function(vec, test_name, num_elements, gen_method, perform_eov, validate_values)
  -- Validate metadata
  local md = loadstring(vec:meta())()
  local is_materialized = false
  local status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed before vec:eov()")
  
  -- calling gen method for nascent vector to generate values ( can be scalar or cmem buffer )
  if gen_method then
    status = vec_utils.generate_values(vec, gen_method, num_elements, md.field_size, md.field_type)
    assert(status, "Failed to generate values for nascent vector")
  end
  
  -- Call vector eov
  if perform_eov == true or perform_eov == nil then
    vec:eov()
    assert(vec:check())
  end
  
  -- Validate vector values
  if validate_values == true or validate_values == nil then
    status = vec_utils.validate_values(vec, md.field_type)
    assert(status, "Vector values verification failed")  
  end
  
  return true
end


local materialized_vec_basic_operations = function(vec, test_name, num_elements, validate_values)
  -- Validate metadata
  local md = loadstring(vec:meta())()
  local is_materialized = true
  local status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed for materialized vector")  
  
  -- Check num elements
  local n = vec:num_elements()
  assert(n == num_elements)
  
  if validate_values == true or validate_values == nil then
    -- Validate vector values
    status = vec_utils.validate_values(vec, md.field_type)
    assert(status, "Vector values verification failed")
  end

  status = vec:persist(true)
  assert(status)
  
  return true
end


fns.assert_nascent_vector1 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = loadstring(vec:meta())()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed after vec:eov()")
  
  --[[
  for i, v in pairs(md) do
    print(i, v)
  end
  os.exit()
  ]]
  
  -- Check file size
  assert(plpath.getsize(md.file_name) == num_elements * md.field_size)
  
  -- Check number of elements in vector
  assert( vec:num_elements() == num_elements )
  
  return true
end


-- Validation when is_memo is false
-- try eov - should not success
-- try adding element after eov -- can not add
fns.assert_nascent_vector2_1 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov(), should be nascent vector as is_memo is false
  local md = loadstring(vec:meta())()
  assert(md.is_nascent == true, "Expected a nascent vector but actual value is not matching")
  assert(md.file_name == nil, "Nascent vector file name should be nil")

  -- Try adding element to eov'd nascent vector, should fail
  local s1 = Scalar.new(123, md.field_type)
  status = vec:put1(s1)
  assert(status == nil, "Able to add value to eov'd nascent vector")
  print(md.num_elements)
  print(vec:num_elements())
  assert(md.num_elements == vec:num_elements(), "Able to add value to eov'd nascent vector")
  assert(vec:check())
  
  return true
end

-- Validation when is_memo is false
-- try persist -- should not work
fns.assert_nascent_vector2_2 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov(), should be nascent vector as is_memo is false
  local md = loadstring(vec:meta())()
  assert(md.is_nascent == true, "Expected a nascent vector but actual value is not matching")
  assert(md.file_name == nil, "Nascent vector file name should be nil")
  
  -- Try persist() method with true, it should fail
  status = vec:persist(true)
  assert(status == nil, "Able set persist even if memo is false")
  
  return true
end

-- Validation when is_memo is false
-- set memo true and try vec:check() -- validation should work
fns.assert_nascent_vector2_3 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov(), should be nascent vector as is_memo is false
  local md = loadstring(vec:meta())()
  assert(md.is_nascent == true, "Expected a nascent vector but actual value is not matching")
  assert(md.file_name == nil, "Nascent vector file name should be nil")
    
  -- Try setting memo to true when chunk_num is zero i.e num_elements < chunk_size
  -- file_name should not be initialized, vec:check() should be successful
  assert(md.chunk_num == 0)
  status = vec:memo(true)
  assert(status, "Failed to update memo even if chunk_num is zero i.e num_elements < chunk_size")
  md = vec:meta()
  assert(vec:check())
  assert(md.file_name == nil, "File name initialized even if num_elements < chunk_size")
  
  return true
end

fns.assert_nascent_vector3 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = true
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov)
  assert(status, "Failed to perform vec basic operations")
    
  -- Validate metadata after vec:eov()
  local md = loadstring(vec:meta())()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed after vec:eov()")

  -- Check file size
  assert(plpath.getsize(md.file_name) == num_elements * md.field_size)
  
  -- Check number of elements in vector
  assert( vec:num_elements() == num_elements )
  
  -- Check read only flag in metadata
  assert(md.is_read_only == true)
  
  -- Try writing to read only vector, it should fail
  local s1 = Scalar.new(123, md.field_type)
  status = vec:set(s1, 0)
  assert(status == nil)
  return true
end

fns.assert_nascent_vector4 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local perform_eov = false
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov)
  assert(status, "Failed to perform vec basic operations")
  
  local md = loadstring(vec:meta())()
  assert(md.is_nascent == true)
  
  -- try to modify Memo, this should work as num_elements == chunk_size
  status = vec:memo(false)
  assert(vec:check())
  assert(status)
  
  -- Add single element so the (num_elements > chunk_size)
  local s1 = Scalar.new(123, md.field_type)
  status = vec:put1(s1)
  assert(vec:check())
  assert(status)
  
  -- Try to modify Memo, this should fail
  status = vec:memo(false)
  assert(vec:check())
  assert(status == nil)
  
  -- Validate metadata
  local md = loadstring(vec:meta())()
  local is_materialized = false
  status = validate_vec_meta(md, is_materialized, num_elements + 1)
  assert(status, "Metadata validation failed")
  
  return true
end

fns.assert_nascent_vector5 = function(vec, test_name, num_elements, gen_method)  
  -- common checks for vectors
  assert(vec:check())
  local md = loadstring(vec:meta())()
  
  -- create base buffer
  local base_data = cmem.new(md.field_size)
  local iptr = ffi.cast(qconsts.qtypes[md.field_type].ctype .. " *", base_data)
  iptr[0] = 121
  
  -- try put chunk
  local status = pcall(vec.put_chunk, base_data, 1)
  assert(status == false)
  
  return true
end

fns.assert_nascent_vector6 = function(vec, test_name, num_elements, gen_method)  
  -- common checks for vectors
  assert(vec:check())
  local md = loadstring(vec:meta())()
  
  -- create base scalar
  local s1 = Scalar.new(123, md.field_type)
  
  -- try put1
  local status = pcall(vec.put1, s1)
  assert(status == false)
  
  return true
end

-- For nascent vector, try get_chunk() without passing chunk_num
-- should return the current chunk
fns.assert_nascent_vector7 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = false
  local validate_values = false
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov, validate_values)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = loadstring(vec:meta())()
  assert(md.is_nascent == true, "Expected a nascent vector, but not a nascent vector")  

  -- Try get_chunk() without passing chunk_num, it should return the current chunk
  local addr, len = vec:get_chunk()
  assert(addr)
  assert(len == md.num_in_chunk)
  
  return true
end


-- nascet vector -> materialized vector (using eov)
-- try modifying the vec using start_write() and end_write()
fns.assert_nascent_vector8_1 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = true
  local validate_values = false
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, nil, validate_values)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = loadstring(vec:meta())()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Try to modify values using start_write()
  local map_addr, num_len = vec:start_write()
  assert(map_addr, "Failed to open the mmaped file in write mode")
  assert(num_len, "Failed to open the mmaped file in write mode")
  local iptr = ffi.cast(qconsts.qtypes[md.field_type].ctype .. " *", map_addr)
  
  -- Set value at index 0
  local test_value = 121
  iptr[0] = test_value
  
  -- close the write handle
  vec:end_write()
  
  -- Now get_chunk() should work as open_mode set to 0, validate modified value
  local addr, len = vec:get_chunk()
  assert(addr)
  iptr = ffi.cast(qconsts.qtypes[md.field_type].ctype .. " *", addr)
  assert(iptr[0] == test_value, "Value mismatch with expected value")
  
  return true
end

-- nascet vector -> materialized vector (using eov)
-- try consecutive operation of get_chunk(), should work
fns.assert_nascent_vector8_2 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations, here a get_chunk operation is happening so open_mode set to 1
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = loadstring(vec:meta())()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Now get_chunk() should work as open_mode set to 1
  local addr, len = vec:get_chunk()
  assert(addr)
  
  return true
end

-- nascent vector -> materialized vector (using eov)
-- try start_write() after read operation, this is not allowed
fns.assert_nascent_vector8_3 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations, here read operation is happening
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = loadstring(vec:meta())()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Try to modify values using start_write()
  local map_addr, num_len = vec:start_write()
  print(map_addr, num_len)
  -- assert(status == false)
  assert(map_addr == nil)
  
  return true
end

-- try to modify values of a vec (nascent -> materialized) using mmap ptr withoud start_write()
fns.assert_nascent_vector9 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = loadstring(vec:meta())()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size
  assert(plpath.getsize(md.file_name) == num_elements * md.field_size, "File size mismatch with expected value")
  
  -- Try to modify values of a read only vector
  local addr, len = vec:get_chunk()
  local iptr = ffi.cast(qconsts.qtypes[md.field_type].ctype .. " *", addr)
  status = pcall(set_value, iptr, 0, 123)
  assert(status == false, "Able to modify read only vector")
  
  return true
end


fns.assert_materialized_vector1 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  
  local md = loadstring(vec:meta())()
  if vec._has_nulls then
    assert(md.nn)
  end

  return true
end

fns.assert_materialized_vector2 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations    
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  local md = loadstring(vec:meta())()

  -- Try setting value at wrong index, this should fail
  local test_value = 101
  local s1 = Scalar.new(test_value, md.field_type)
  status = vec:set(s1, num_elements + 1)
  assert(status == nil)
  
  return true
end

-- try eov over materialized vector
fns.assert_materialized_vector3 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations    
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")  
  local md = loadstring(vec:meta())()

  status = vec:eov()
  assert(status == nil)
  
  assert(vec:check())
  
  return true
end

fns.assert_materialized_vector4 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations    
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")  
  local md = loadstring(vec:meta())()
  
  -- Try setting value
  local test_value = 101
  local s1 = Scalar.new(test_value, md.field_type)
  status = vec:set(s1, 0)
  assert(status == nil)
  
  return true
end

fns.assert_materialized_vector5 = function(vec, test_name, num_elements)
  assert(vec == nil)
  return true
end


-- try modifying values of materialized vector with start_write()
fns.assert_materialized_vector6 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local validate_values = false
  local status = materialized_vec_basic_operations(vec, test_name, num_elements, validate_values)
  assert(status, "Failed to perform materialized vec basic operations")

  local md = loadstring(vec:meta())()
  
  -- Try to modify value using start_write()
  local map_addr, num_len = vec:start_write()
  assert(map_addr, "Failed to open the mmaped file in write mode")
  assert(num_len, "Failed to open the mmaped file in write mode")
  local iptr = ffi.cast(qconsts.qtypes[md.field_type].ctype .. " *", map_addr)
  
  -- Set value at index 0
  local test_value = 121
  iptr[0] = test_value
  
  -- close the write handle
  vec:end_write()
  
  -- Now get_chunk() should work as open_mode set to 0, validate modified value
  local addr, len = vec:get_chunk()
  assert(addr)
  iptr = ffi.cast(qconsts.qtypes[md.field_type].ctype .. " *", addr)
  assert(iptr[0] == test_value, "Value mismatch with expected value")
  
  assert(vec:check())

  return true
end

return fns
