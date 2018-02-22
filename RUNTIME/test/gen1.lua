local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'  

local counter = 1
local chunk_size = qconsts.chunk_size
local field_size = ffi.sizeof("int32_t")
local bytes_to_alloc = field_size * chunk_size
local b1 = cmem.new(bytes_to_alloc, "I4", "gen1_buffer")

local function gen1(chunk_idx, col)
  if ( chunk_idx == 8 ) then 
    return 0, nil, nil 
  end
  local b2 = ffi.cast("CMEM_REC_TYPE *", b1)
  local iptr = ffi.cast("int32_t *", b2[0].data)
  for i = 1, chunk_size do
    iptr[i-1] = counter
    counter = counter + 1
  end
  return chunk_size, b1, nil
end
return gen1

