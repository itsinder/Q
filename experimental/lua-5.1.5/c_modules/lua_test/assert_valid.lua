local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local dbg    = require 'Q/UTILS/lua/debugger'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local fns = {}

--===================
local pr_meta = function (x, file_name)
  local T = loadstring(x:meta())()
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

fns.assert_nascent_vector = function(vec, test_name, num_elements, field_size, gen_method)
  vec:eov()
  --local md = pr_meta(vec, script_dir.. "/_meta_"..test_name)
  local md = loadstring(vec:meta())()
  assert(plpath.getsize(md.file_name) == num_elements * field_size)
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