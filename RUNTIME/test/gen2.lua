local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'  
-- local lVector = require 'lVector'

local l_chunk_num = 1  -- no connection to Vector's chunk num
local counter = 1
local chunk_size = qconsts.chunk_size
local field_size = 4

local function gen2(chunk_idx, col)
  print("1: counter =, l_chunk_num = ", counter, l_chunk_num)
  local base_data, nn_data = col:get_vec_buf()
  assert(base_data)
  local iptr = ffi.cast("int32_t *", base_data)
  local buf_size = chunk_size
  if ( l_chunk_num == 2 ) then 
    buf_size = 100000 - chunk_size
  end
  if ( l_chunk_num > 2 ) then 
    return false
  end
  for i = 1, buf_size do
    iptr[i-1] = counter
    counter = counter + 1
  end
  print("returning ", buf_size)
  col:release_vec_buf(buf_size)
  l_chunk_num = l_chunk_num + 1
  return buf_size
end
return gen2
