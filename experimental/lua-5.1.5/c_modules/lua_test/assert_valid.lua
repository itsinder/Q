local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local dbg    = require 'Q/UTILS/lua/debugger'
local vec_utils = require 'Q/experimental/lua-515/c_modules/lua_test/vec_utility'
local Scalar  = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local fns = {}

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


local vec_basic_operations = function(vec, test_name, num_elements, gen_method, perform_eov, is_read_only)
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
    vec:eov(is_read_only)
    assert(vec:check())
  end
  
  -- Validate vector values
  status = vec_utils.validate_values(vec, md.field_type)
  assert(status, "Vector values verification failed")  
  
  return true
end


fns.assert_nascent_vector1 = function(vec, test_name, num_elements, gen_method)
  -- Perform vec basic operations
  local status = vec_basic_operations(vec, test_name, num_elements, gen_method)
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


fns.assert_nascent_vector2 = function(vec, test_name, num_elements, gen_method)
  -- Perform vec basic operations  
  local status = vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
      
  -- Validate metadata after vec:eov()
  local md = loadstring(vec:meta())()
  assert(md.is_nascent == true)
  assert(md.file_name == nil)
  
  return true
end


fns.assert_nascent_vector3 = function(vec, test_name, num_elements, gen_method)
  -- Perform vec basic operations
  local perform_eov = true
  local is_read_only = true
  local status = vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov, is_read_only)
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
  -- Perform vec basic operations  
  local perform_eov = false
  local status = vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov)
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

fns.assert_materialized_vector = function(vec, test_name, num_elements)
  -- Validate metadata
  local md = loadstring(vec:meta())()
  local is_materialized = true
  local status = validate_vec_meta(md, is_materialized)
  assert(status, "Metadata validation failed for materialized vector")  
  
  -- Check num elements
  local n = vec:num_elements()
  print("length of vector",n)
  assert(n == num_elements)
  
  -- Validate vector values
  status = vec_utils.validate_values(vec, md.field_type)
  assert(status, "Vector values verification failed")
  
  -- Try setting value
  local test_value = 101
  local s1 = Scalar.new(test_value, md.field_type)
  status = vec:set(s1, 0)
  assert(status)
  assert(vec:check())
  
  -- Validate modified value
  local ret_addr, ret_len = vec:get_chunk(0);
  assert(test_value == ffi.cast(qconsts.qtypes[md.field_type].ctype .. " *", ret_addr)[0])
  
  return true
end

return fns