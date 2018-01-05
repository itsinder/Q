local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'  

local counter = 1
local chunk_size = qconsts.chunk_size
local field_size = 4
local base_data = cmem.new(chunk_size * field_size)

local function gen4(chunk_idx, col)
  if ( chunk_idx == 3 ) then
    -- generate less than chunk size values for this chunk
    chunk_size = 10 
  end
  local iptr = ffi.cast("int32_t *", base_data)
  for i = 1, chunk_size do
    iptr[i-1] = counter
    counter = counter + 1
  end
  return chunk_size, base_data, nil
end
return gen4
