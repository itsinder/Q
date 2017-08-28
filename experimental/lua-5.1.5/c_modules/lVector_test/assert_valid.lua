local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local dbg    = require 'Q/UTILS/lua/debugger'
local vec_utils = require 'Q/experimental/lua-515/c_modules/lVector_test/vec_utility'
local Scalar  = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local fns = {}
--[[
--===================
local pr_meta = function (x, file_name)
  local T = x:meta()
  local temp = io.output() -- this is for debugger to work 
  io.output(file_name)
  io.write(" return { ")
  for k1, v1 in pairs(T) do 
    for k2, v2 in pairs(v1) do 
      io.write(k1 .. "_" ..  k2 .. " = \"" .. tostring(v2) .. "\",")
      io.write("\n")
    end
  end
  io.write(" } ")
  io.close()
  io.output(temp) -- this is for debugger to work 
  return T
end
--=========================
local compare = function (f1, f2)
  local s1 = plfile.read(f1)
  local s2 = plfile.read(f2)
  assert(s1 == s2, "mismatch in " .. f1 .. " and " .. f2)
end
--=========================
]]
--===================
local validate_vec_meta = function(meta, is_materialized, num_elements)
  local status = true
  if is_materialized then
    assert(meta.base.is_nascent == false)
    assert(meta.base.file_name)
    assert(plpath.exists(meta.base.file_name))
  else
    assert(meta.base.is_nascent == true)
  end
  
  if num_elements and not is_materialized then
    assert(meta.base.chunk_num == math.floor(num_elements / qconsts.chunk_size))
    assert(meta.base.num_in_chunk == num_elements % qconsts.chunk_size)
    assert(meta.base.num_elements == num_elements)
  end
  return status
end

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
    assert(vec:check())
  end
  
  -- Validate vector values
  if gen_method ~= "func" then 
    status = vec_utils.validate_values(vec, md.base.field_type)
    assert(status, "Vector values verification failed")  
  end
  md = vec:meta()
  return true
end


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



fns.assert_nascent_vector1 = function(vec, test_name, num_elements, gen_method)
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
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
  assert(plpath.getsize(md.base.file_name) == num_elements * md.base.field_size)
  
  -- Check number of elements in vector
  assert( vec:num_elements() == num_elements )
  
  return true
end


fns.assert_nascent_vector2 = function(vec, test_name, num_elements, gen_method)
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
  assert(plpath.getsize(md.base.file_name) == num_elements * chunk_size * md.base.field_size)
  
  -- Check number of elements in vector
  assert( vec:num_elements() == num_elements * chunk_size )
  
  return true
end


fns.assert_materialized_vector1 = function(vec, test_name, num_elements)
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  local md = vec:meta()
  
  --[[
  -- Try setting value
  local test_value = 101
  local s1 = Scalar.new(test_value, md.base.field_type)
  status = vec:put1(s1)
  assert(status)
  assert(vec:check())
  
  -- Validate modified value
  local ret_addr, ret_len = vec:get_chunk(0);
  assert(test_value == ffi.cast(qconsts.qtypes[md.base.field_type].ctype .. " *", ret_addr)[0])
  ]]
  return true
end


return fns