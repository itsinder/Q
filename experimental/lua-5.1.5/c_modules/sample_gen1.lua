local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'  
local lVector = require 'lVector'

local counter = 1
local chunk_size = qconsts.chunk_size
local field_size = 4
local base_data = cmem.new(chunk_size * field_size)

local function sample_gen1(chunk_idx, col)
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, chunk_size do
    iptr[i-1] = counter
    counter = counter + 1
  end
  col:put_chunk(base_data, nil, chunk_size)
  return true
end
return sample_gen1

