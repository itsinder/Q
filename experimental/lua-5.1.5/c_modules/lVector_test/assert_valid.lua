local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local dbg    = require 'Q/UTILS/lua/debugger'
local vec_utils = require 'Q/experimental/lua-515/c_modules/lVector_test/vec_utility'
local Scalar  = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local fns = {}

--===================
local validate_vec_meta = function(meta, is_materialized, num_elements)
  local status = true
  if is_materialized then
    if meta.base.is_nascent ~= false or not meta.base.file_name or not plpath.exists(meta.base.file_name) then
      status = false
    end
    --[[
    assert(meta.base.is_nascent == false)
    assert(meta.base.file_name)
    assert(plpath.exists(meta.base.file_name))
    ]]
  else
    if meta.base.is_nascent ~= true then
      status = false
    end
  end
  
  if status and num_elements and not is_materialized then
    if meta.base.chunk_num ~= math.floor(num_elements / qconsts.chunk_size) then
      print("chunk_number validation failed")
      return false
    end
    if meta.base.num_in_chunk ~= num_elements % qconsts.chunk_size then
      print("num_in_chunk validation failed")
      return false
    end
    if meta.base.num_elements ~= num_elements then
      print("num_elements verification failed")
      return false
    end
  end
  return status
end
--===================

local nascent_vec_basic_operations = function(vec, test_name, num_elements, gen_method, perform_eov, is_read_only)
  -- Validate metadata
  local md = vec:meta()
  local is_materialized = false
  local status = validate_vec_meta(md, is_materialized)
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
  local status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed for materialized vector")  
  
  -- Check num elements
  local n = vec:num_elements()
  assert(n == num_elements)
  
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
  status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size
  assert(plpath.getsize(md.base.file_name) == num_elements * md.base.field_size, "File size mismatch with expected value")
  
  -- Check number of elements in vector
  assert( vec:num_elements() == num_elements, "Num elements mismatch with actual value")
  
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
  local md = vec:meta()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed after vec:eov()")
  
  local chunk_size = qconsts.chunk_size
  -- Check file size
  assert(plpath.getsize(md.base.file_name) == num_elements * chunk_size * md.base.field_size, "File size mismatch with expected value")
  
  -- Check number of elements in vector
  assert( vec:num_elements() == num_elements * chunk_size, "Num elements mismatch with actual value")
  
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
  status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size
  assert(plpath.getsize(md.base.file_name) == num_elements * md.base.field_size, "File size mismatch with expected value")
  
  -- Check number of elements in vector
  assert( vec:num_elements() == num_elements, "Num elements mismatch with actual value")
    
  -- Check read only flag in metadata
  assert(md.base.is_read_only == true, "not a read only vector")
  
  -- Try to modify values of a read only vector
  local len, base_data, nn_data = vec:get_chunk()
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  status = pcall(loadstring("iptr[0] = 123"))
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

fns.assert_materialized_vector1 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  --[[
  local md = vec:meta()
  
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
  status = pcall(loadstring("iptr[num_elements+1] = test_value"))
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
  status = pcall(loadstring("iptr[0] = test_value"))
  assert(status == false, "Able to modify value of read only materialized vector")
  assert(vec:check())

  return true
end
--===================

fns.assert_materialized_vector5 = function(vec, test_name, num_elements)
  assert(vec == nil)
  return true
end

return fns