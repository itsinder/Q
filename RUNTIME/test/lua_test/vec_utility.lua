local ffi     = require 'Q/UTILS/lua/q_ffi'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'

local fns = {}

fns.validate_values = function(vec, qtype, chunk_number)
  -- Temporary: no validation of vector values for B1 type  
  if qtype == "B1" then
    return true
  end
  
  local status = true
  local ret_addr, ret_len = vec:get_chunk(chunk_number);
  assert(ret_addr)
  assert(ret_len)
  local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", ret_addr)
  for i =  1, ret_len do
    local expected = i*15 % qconsts.qtypes[qtype].max
    if ( iptr[i - 1] ~= expected ) then
      status = false
      print("Value mismatch at index " .. tostring(i) .. ", expected: " .. tostring(expected) .. " .... actual: " .. tostring(iptr[i - 1]))
      break
    end
  end
  return status
end

-- for generating values ( can be scalar, gen_func, cmem_buf )
fns.generate_values = function( vec, gen_method, num_elements, field_size, qtype)
  local status = false
  local buf_length = num_elements
  if gen_method == "cmem_buf" then 
    if qtype == "B1" then 
      -- We will populate a buffer by putting 8 bits at a time
      field_size = 8
      qtype = "I1"
      num_elements = math.ceil(num_elements / 8)
    end
      
    local base_data = cmem.new(num_elements * field_size)
    local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", base_data)
    --iptr[0] = qconsts.qtypes[qtype].min
    for itr = 1, num_elements do
      iptr[itr - 1] = itr*15 % qconsts.qtypes[qtype].max
    end
    --iptr[num_elements - 1] = qconsts.qtypes[qtype].max
    vec:put_chunk(base_data, buf_length)
    assert(vec:check())
    status = true
  end
  
  if gen_method == "scalar" then
    for i = 1, num_elements do
      local s1, s1_nn
      if qtype == "B1" then
        local bval
        if i % 2 == 0 then bval = true else bval = false end
        s1 = Scalar.new(bval, qtype)
      else
        s1 = Scalar.new(i*15% qconsts.qtypes[qtype].max, qtype)
      end
      if vec._has_nulls then
        local bval
        if i % 2 == 0 then bval = true else bval = false end
        s1_nn = Scalar.new(bval, "B1")
      end
      vec:put1(s1, s1_nn)
    end
    --s1 = Scalar.new(qconsts.qtypes[qtype].max, qtype)
    --vec:put1(s1)    
    status = true
  end
  return status
end

return fns
