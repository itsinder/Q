local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'  
local lVector = require 'lVector'

local chunk_num = 1 
local counter = 1
local chunk_size = qconsts.chunk_size
local field_size = 4

local function sample_gen1(chunk_idx, col)
  local base_data, nn_data = col:get_vec_buf()
  local dbg    = require 'Q/UTILS/lua/debugger'
  dbg()
  local iptr = ffi.cast("int32_t *", base_data)
  if ( chunk_num == 2 ) then 
    chunk_size = 100000 - chunk_size
  end
  if ( chunk_num > 2 ) then 
    return 
  end
  for i = 1, chunk_size do
    iptr[i-1] = counter
    counter = counter + 1
  end
  col:put_chunk(base_data, nil, chunk_size)
  chunk_num = chunk_num + 1
  return true
end
return sample_gen1

