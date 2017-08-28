local ffi     = require 'Q/UTILS/lua/q_ffi'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'

local fns = {}

fns.validate_values = function(vec, qtype, chunk_number)
  local status = true
  -- local ret_addr, ret_len = vec:get_chunk(chunk_number);
  local len, base_data, nn_data = vec:get_chunk()
  assert(base_data)
  assert(len)
  local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", base_data)
  for i =  1, len do
    local expected = i*15 % qconsts.qtypes[qtype].max
    if ( iptr[i - 1] ~= expected ) then
      status = false
      print("Value mismatch at index " .. tostring(i) .. ", expected: " .. tostring(expected) .. " .... actual: " .. tostring(iptr[i - 1]))
    end
  end
  return status
end


-- for generating values ( can be scalar, gen_func, cmem_buf )
fns.generate_values = function( vec, gen_method, num_elements, field_size, qtype)
  local status = false
  if gen_method == "cmem_buf" then 
    local base_data = cmem.new(num_elements * field_size)
    local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", base_data)
    --iptr[0] = qconsts.qtypes[qtype].min
    for itr = 1, num_elements do
      iptr[itr - 1] = itr*15 % qconsts.qtypes[qtype].max
    end
    --iptr[num_elements - 1] = qconsts.qtypes[qtype].max
    vec:put_chunk(base_data,nil, num_elements)
    assert(vec:check())
    status = true
  end
  
  if gen_method == "scalar" then
    --local s1 = Scalar.new(qconsts.qtypes[qtype].min, qtype)
    --vec:put1(s1)
    for i = 1, num_elements do
      local s1 = Scalar.new(i*15 % qconsts.qtypes[qtype].max, qtype)
      vec:put1(s1)
    end
    --s1 = Scalar.new(qconsts.qtypes[qtype].max, qtype)
    --vec:put1(s1)    
    status = true
  end
  
  if gen_method == "func" then
    local num_chunks = num_elements
    local chunk_size = qconsts.chunk_size
    for chunk_num = 1, num_chunks do 
      local a, b, c = vec:get_chunk(chunk_num-1)
      assert(a == chunk_size)
    end
    status = true
  end
  
  return status
end

return fns