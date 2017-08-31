local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local dbg    = require 'Q/UTILS/lua/debugger'
local vec_utils = require 'Q/experimental/lua-515/c_modules/lVector_test/vec_utility'
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
  
  -- meta.base checks
  assert(meta.base.num_elements == num_elements)
  if is_materialized then
    assert(meta.base.is_nascent == false)
    assert(meta.base.file_name)
    assert(plpath.exists(meta.base.file_name))
    assert(meta.base.chunk_num == 0)
    assert(meta.base.num_in_chunk == 0)    
  else
    assert(meta.base.is_nascent == true)
    assert(meta.base.file_name == nil)
    assert(meta.base.chunk_num == math.floor(num_elements / qconsts.chunk_size))
    assert(meta.base.num_in_chunk == num_elements % qconsts.chunk_size)    
  end
  
  -- meta.nn checks
  if meta.nn then
    assert(meta.nn.num_elements == num_elements)
    if is_materialized then
      assert(meta.nn.is_nascent == false)
      assert(meta.nn.file_name)
      assert(plpath.exists(meta.nn.file_name))
      assert(meta.nn.chunk_num == 0)
      assert(meta.nn.num_in_chunk == 0)    
    else
      assert(meta.nn.is_nascent == true)
      assert(meta.nn.file_name == nil)
      assert(meta.nn.chunk_num == math.floor(num_elements / qconsts.chunk_size))
      assert(meta.nn.num_in_chunk == num_elements % qconsts.chunk_size)    
    end    
  end
  
  return status
end
--===================

local nascent_vec_basic_operations = function(vec, test_name, num_elements, gen_method, perform_eov, is_read_only)
  -- Validate metadata
  local md = vec:meta()
  local is_materialized = false
  local status = validate_vec_meta(md, is_materialized, 0)
  assert(status, "Metadata validation failed before vec:eov()")
  
  -- calling gen method for nascent vector to generate values ( can be scalar or cmem buffer )
  if gen_method then
    status = vec_utils.generate_values(vec, gen_method, num_elements, md.base.field_size, md.base.field_type)
    assert(status, "Failed to generate values for nascent vector")
  end
  
  -- Call vector eov
  if perform_eov == true or perform_eov == nil then
    vec:eov(is_read_only)
    status = vec:check()
    assert(vec:check(), "Failed in vector check after vec:eov()")
  end
  
  -- Validate vector values
  -- TODO: modify validate values to work with gen_method == func
  if gen_method ~= "func" then 
    status = vec_utils.validate_values(vec, md.base.field_type)
    assert(status, "Vector values verification failed")
  end
  return true
end
--===================

local materialized_vec_basic_operations = function(vec, test_name, num_elements)
  -- Validate metadata
  local md = vec:meta()
  local is_materialized = true
  local status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed for materialized vector")  
    
  -- Validate vector values
  status = vec_utils.validate_values(vec, md.base.field_type)
  assert(status, "Vector values verification failed")
  
  status = vec:persist(true)
  assert(status)
  
  return true
end
--===================

fns.assert_nascent_vector1 = function(vec, test_name, num_elements, gen_method)  
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size for base
  local expected_file_size
  if md.base.field_type == "B1" then
    expected_file_size = (math.ceil(num_elements/64.0) * 64) / 8
  else
    expected_file_size = num_elements * md.base.field_size
  end
  local actual_file_size = plpath.getsize(md.base.file_name)
  assert(actual_file_size == expected_file_size, "File size mismatch with expected value")

  if md.nn then
    -- Check file size for nn
    expected_file_size = (math.ceil(num_elements/64.0) * 64) / 8
    actual_file_size = plpath.getsize(md.nn.file_name)
    assert(actual_file_size == expected_file_size, "File size mismatch with expected value")
  end
  
  return true
  
end
--===================

fns.assert_nascent_vector2 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local chunk_size = qconsts.chunk_size
  local md = vec:meta()
  local is_materialized = true
  -- for gen function, num_elements = num_of_chunks * chunk_size
  -- here, arg num_elements represents num_of_chunks
  status = validate_vec_meta(md, is_materialized, num_elements * chunk_size)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size
  assert(plpath.getsize(md.base.file_name) == num_elements * chunk_size * md.base.field_size, "File size mismatch with expected value")

  return true
end
--===================

fns.assert_nascent_vector3 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  assert(md.base.is_nascent == true, "Expected a nascent vector but actual value is not matching")
  assert(md.base.file_name == nil, "Nascent vector file name should be nil")
  
  -- Try persist() method with true, it should fail
  status = vec:persist(true)
  assert(status == nil, "Able set persist even if memo is false")
  
  return true
end
--===================

fns.assert_nascent_vector4 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = true
  local is_read_only = true
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov, is_read_only)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size
  assert(plpath.getsize(md.base.file_name) == num_elements * md.base.field_size, "File size mismatch with expected value")
  
  -- Check read only flag in metadata
  assert(md.base.is_read_only == true, "not a read only vector")
  
  -- Try to modify values of a read only vector
  local len, base_data, nn_data = vec:get_chunk()
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  status = pcall(set_value, iptr, 0, 123)
  assert(status == false, "Able to modify read only vector")
  return true
end
--===================

fns.assert_nascent_vector5 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = false
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  assert(md.base.is_nascent == true, "Expected a nascent vector, but not a nascnet vector")
  
  -- try to modify Memo, this should work as num_elements == chunk_size
  status = vec:memo(false)
  assert(status, "Failed to modify memo even if first chunk is not flushed")
  assert(vec:check())
  assert(status)
  
  -- Add single element so the (num_elements > chunk_size)
  local s1 = Scalar.new(123, md.base.field_type)
  status = vec:put1(s1)
  assert(vec:check())
  
  -- Try to modify Memo, this should fail
  status = vec:memo(false)
  assert(vec:check())
  assert(status == nil, "Able to modify memo even after first chunk is flushed")
  
  -- Validate metadata
  md = vec:meta()
  local is_materialized = false
  status = validate_vec_meta(md, is_materialized, num_elements + 1)
  assert(status, "Metadata validation failed")
  
  return true
end
--===================

fns.assert_nascent_vector6 = function(vec, test_name, num_elements, gen_method)  
  -- common checks for vectors
  assert(vec:check())
  local md = vec:meta()
  
  -- create base buffer
  local base_data = cmem.new(md.base.field_size)
  local iptr = ffi.cast(qconsts.qtypes[md.base.field_type].ctype .. " *", base_data)
  iptr[0] = 121
  
  -- try put chunk
  local status = pcall(vec.put_chunk, vec, base_data, nil, 1)
  assert(status == false)
  
  return true
end
--===================

fns.assert_nascent_vector7 = function(vec, test_name, num_elements, gen_method)  
  -- common checks for vectors
  assert(vec:check())
  local md = vec:meta()
  
  -- create base scalar
  local s1 = Scalar.new(123, md.base.field_type)
  
  -- try put1
  local status = pcall(vec.put1, vec, s1)
  assert(status == false)
  
  return true
end
--===================

fns.assert_materialized_vector1 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  
  local md = vec:meta()
  if vec._has_nulls then
    assert(md.nn)
  end
  --[[
  -- Try setting value
  local test_value = 101
  local len, base_data, nn_data = vec:get_chunk()
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  iptr[0] = test_value
  
  assert(vec:check())
  
  -- Validate modified value
  len, base_data, nn_data = vec:get_chunk()
  iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  assert(test_value == iptr[0])
  ]]
  return true
end
--===================

fns.assert_materialized_vector2 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")

  local md = vec:meta()
  
  -- Try setting value at wrong index
  local test_value = 101
  local len, base_data, nn_data = vec:get_chunk()
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  status = pcall(set_value, iptr, num_elements+1, test_value)
  assert(status == false, "Able to modify value at wrong index for materialized vector")
  assert(vec:check())

  return true
end
--===================

fns.assert_materialized_vector3 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  
  -- Try setting value at wrong index
  status = vec:eov()
  assert(status == nil)

  assert(vec:check())

  return true
end
--===================

fns.assert_materialized_vector4 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")

  local md = vec:meta()
  
  -- Try setting value where vec is read only
  local test_value = 101
  local len, base_data, nn_data = vec:get_chunk()
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  status = pcall(set_value, iptr, 0, test_value)
  assert(status == false, "Able to modify value of read only materialized vector")
  assert(vec:check())

  return true
end
--===================

fns.assert_materialized_vector5 = function(vec, test_name, num_elements)
  assert(vec == nil)
  return true
end
--===================

fns.assert_materialized_vector6 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  
  local md = vec:meta()
  if vec._has_nulls then
    assert(md.nn)
  end
  
  -- Try setting value
  local test_value = 101
  local len, base_data, nn_data = vec:get_chunk()
  assert(nn_data)
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  status = pcall(set_value, iptr, 0, test_value)
  
  -- Above should fail, 
  -- as we are modifying materialized vector with nulls without modifying respective nn vec
  assert(status == false)
  
  return true
end
--===================

return fns