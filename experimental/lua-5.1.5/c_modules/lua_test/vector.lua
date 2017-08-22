local Vector = require 'libvec'
local cmem    = require 'libcmem'
local Scalar  = require 'libsclr'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'

local generate_values = function( vec, gen_method, num_elements, field_size, qtype)
  local status = false
  if gen_method == "cmem_buf" then 
    local base_data = cmem.new(num_elements * field_size)
    local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", base_data)
    iptr[0] = qconsts.qtypes[qtype].min
    for itr = 1, num_elements - 2 do
      iptr[itr] = itr*15 % qconsts.qtypes[qtype].max
    end
    iptr[num_elements - 1] = qconsts.qtypes[qtype].max
    vec:put_chunk(base_data, num_elements)
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
  return status
end

-- input args are in the order below
-- M - metadata containing qtype, file_name, is_read_only, is_memo, num_elements depending on vector type (nascent / materialized)
return function( M, gen_method )
  assert(M.qtype, "qtype is not provided")
  
  -- Check for SC type
  if M.qtype == "SC" then
    assert(M.field_size, "Field size is not provided for SC")
    assert(type(M.field_size) == "number", "Provided field_size is not number")
    M.qtype = "SC:" .. M.field_size
  end
  
  -- Create Vector
  local x = Vector.new(M.qtype, M.file_name, M.is_read_only, M.is_memo, M.num_elements)
  local field_size
  if M.field_size then
    field_size = M.field_size
  else
    field_size = qconsts.qtypes[M.qtype].width
  end
  -- calling gen method of nascent vector 
  -- for generating values ( can be scalar or cmem buffer )
  if gen_method then 
    local status = generate_values(x, gen_method, M.num_elements, field_size, M.qtype)
    assert(status, "Failed to generate values for nascent vector")
  end
  return x
end