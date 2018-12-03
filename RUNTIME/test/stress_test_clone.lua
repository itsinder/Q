local lVector	= require 'Q/RUNTIME/lua/lVector'
local tests = {}
local niters = 1000000
--====== Testing with more than chunk size
tests.t1 = function()
  local len = qconsts.chunk_size * 2 + 1
  local x = Q.const( {val = num, qtype = "I4", len = len })
  for i = 1, niters do y = Q.clone(x) end
  x:eval()
  for i = 1, niters do y = Q.clone(x) end
  print("Successfully completed test t1")
end
--====== Testing with less than chunk size 
tests.t1 = function()
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local len = qconsts.chunk_size - 1 
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, num_elements do
    iptr[i-1] = i*10
  end
  x:put_chunk(base_data, nil, num_elements)
  for i = 1, niters do y = Q.clone(x) end
  x:eov()
  for i = 1, niters do y = Q.clone(x) end
  print("Successfully completed test t2")
end

return tests
