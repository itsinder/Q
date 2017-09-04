local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'

local chunk_size = qconsts.chunk_size

local function gen1(chunk_idx, col)
  local field_size = col:field_size()
  local base_data = cmem.new(chunk_size * field_size)
  local iptr = ffi.cast(qconsts.qtypes[col:qtype()].ctype .. " *", base_data)
  for i = 1, chunk_size do
    iptr[i-1] = i*15 % qconsts.qtypes[col:qtype()].max
  end
  return chunk_size, base_data, nil
end
return gen1
