local lVector = require 'Q/experimental/lua-515/c_modules/lVector'
local cmem    = require 'libcmem'
local Scalar  = require 'libsclr'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'

-- TODO: generating values can be separated out 
-- in a different function( called generate_values)
-- gen can be taken from map_file as boolean or function name
-- if gen points to a function then pass control there
-- if gen doesn't point to a function then generate the values 
-- here in generate_values function like itr*10 
local generate_values = function( vec, gen_method, num_elements, field_size, qtype)
  local base_data = cmem.new(num_elements * field_size)
  local ctype = qconsts.qtypes[qtype].ctype
  local iptr = ffi.cast(ctype .. " *", base_data)

  if gen_method == "itr" then 
    for itr = 1, num_elements do
      iptr[itr-1] = itr*10
    end
    vec:put_chunk(base_data, nil, num_elements)
    return vec
  end
  
  if gen_method == "scalar" then
    for i = 1, num_elements do
      local s1 = Scalar.new(i*11, qtype)
      vec:put1(s1)
    end
    return vec
  end
  
  if gen_method == "func" then
    local num_chunks = 10
    local chunk_size = qconsts.chunk_size
    for chunk_num = 1, num_chunks do 
      local a, b, c = vec:get_chunk(chunk_num-1)
      assert(a == chunk_size)
    end
    return vec
  end
end

-- input args are in the order below
-- M - metadata required for lVector constructor
-- num_elements - required by generate_values function
-- field_size - required by generate_values function
return function( M, gen_method, num_elements , field_size)
  local x = lVector( M )
  -- calling gen method of nascent vector 
  -- for generating values ( can be scalar, gen_func, iter )
  if gen_method then 
    local vector, num_chunks, chunk_size = generate_values(x, gen_method, num_elements, field_size, M.qtype)
    return vector
  end
  return x
end