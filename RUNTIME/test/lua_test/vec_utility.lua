local ffi     = require 'Q/UTILS/lua/q_ffi'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'

local fns = {}

fns.validate_values = function(vec, qtype, chunk_number)
  local status = true
  
  local ret_addr, ret_len = vec:get_chunk(chunk_number)
  assert(ret_addr)
  assert(ret_len)
  
  -- Validation of B1 vector values is working for cmem_buf
  
  if qtype == "B1" then
    qtype = "I1"
    ret_len = math.ceil( vec:num_elements() / 8 )
  end
  
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
      --print("value ",itr,iptr[itr - 1],qtype)
    end
    --iptr[num_elements - 1] = qconsts.qtypes[qtype].max
    vec:put_chunk(base_data, buf_length)
    assert(vec:check())
    status = true
  end
  
  -- TODO: Scalar generation for B1 is not working as desired
  
  if gen_method == "scalar" then
    for i = 1, num_elements do
      local s1
      if qtype == "B1" then
        local bval
        if i % 2 == 0 then bval = true else bval = false end
        s1 = Scalar.new(bval, qtype)
      else
        s1 = Scalar.new(i*15% qconsts.qtypes[qtype].max, qtype)
      end
      vec:put1(s1)
    end
    --s1 = Scalar.new(qconsts.qtypes[qtype].max, qtype)
    --vec:put1(s1)    
    status = true
  end
  return status
end

return fns
