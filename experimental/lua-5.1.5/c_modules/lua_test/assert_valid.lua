local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local dbg    = require 'Q/UTILS/lua/debugger'
local vec_utils = require 'Q/experimental/lua-515/c_modules/lua_test/vec_utility'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local fns = {}

--===================
local validate_meta = function(meta, is_eov)
  local status = true
  if is_eov then
    assert(meta.is_nascent == false)
    assert(meta.file_name)
    assert(plpath.exists(meta.file_name))
  else
    assert(meta.is_nascent == true)
  end
  return status
end

fns.assert_nascent_vector1 = function(vec, test_name, num_elements, gen_method)
  -- Validate metadata
  local md = loadstring(vec:meta())()
  local status = validate_meta(md, false)
  assert(status, "Metadata validation failed before vec:eov()")
  
  -- calling gen method for nascent vector to generate values ( can be scalar or cmem buffer )
  if gen_method then
    status = vec_utils.generate_values(vec, gen_method, num_elements, md.field_size, md.field_type)
    assert(status, "Failed to generate values for nascent vector")
  end
  
  -- Call vector eov
  vec:eov()
  assert(vec:check())
  
  -- Validate vector values
  status = vec_utils.validate_values(vec, md.field_type)
  assert(status, "Vector values verification failed")
  
  -- Validate metadata after vec:eov()
  md = loadstring(vec:meta())()
  status = validate_meta(md, true)
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


fns.assert_materialized_vector = function(vec, test_name, num_elements)
  pr_meta(vec, script_dir.. "/_meta_"..test_name)
  local n = vec:num_elements()
  print("length of vector",n)
  -- assert(n == num_elements)
  local len, base_data, nn_data = vec:get_chunk()
  assert(base_data)
  assert(not nn_data)
  assert(len)
  
  len, base_data, nn_data = vec:get_chunk(100)
  assert(not base_data)
  assert(not nn_data)
  
  return true
end

return fns