local function cat(x, y)
  local lVector     = require 'Q/RUNTIME/lua/lVector'
  local base_qtype  = require 'Q/UTILS/lua/is_base_qtype'
  local qconsts     = require 'Q/UTILS/lua/q_consts'
  local ffi         = require 'Q/UTILS/lua/q_ffi'
  assert(type(x) == "lVector", "x must be a vector")
  assert(type(y) == "lVector", "y must be a vector")
  assert(x:fldtype() == y:fldtype(), "both vectors must have same type")
  assert(x:has_nulls() == y:has_nulls(), "either both have nulls or neither has nulls, we will relax this assumption later")
  
  -- Create output vector
  local qtype = x:fldtype()
  local width = qconsts.qtypes[x:fldtype()].width
  local chunk_size = qconsts.chunk_size
  local z_buf_size = chunk_size * width
  local z_buf = ffi.malloc(z_buf_size)
  ffi.fill(z_buf, z_buf_size)
  local chunk_idx = 0
  
  -- Create z vector
  local z = lVector({qtype = qtype, gen = true, has_nulls = x:has_nulls()})
  
  -- Process X vector
  repeat
    local len, base_data, nn_data = x:chunk(chunk_idx)
    if len > 0 then
      -- Can't use base_data directly for put_chunk is it is not of type CMEM
      ffi.copy(z_buf, base_data, width * len)
      z:put_chunk(z_buf, nn_data, len)
      ffi.fill(z_buf, z_buf_size)
    end
    chunk_idx = chunk_idx + 1
  until(len ~= chunk_size)
 
  -- Initialize chunk_idx to zero
  chunk_idx = 0
  
  -- Process Y Vector
  repeat
    local len, base_data, nn_data = y:chunk(chunk_idx)
    if len > 0 then
      ffi.copy(z_buf, base_data, width * len)
      z:put_chunk(z_buf, nn_data, len)
      ffi.fill(z_buf, z_buf_size)
    end
    chunk_idx = chunk_idx + 1
  until(len ~= chunk_size)  
  
  -- EOV the output vector 
  z:eov()
  
  -- nullify all meta data that might have been rendered invalid
  -- z:set_meta("sort_order") --  set sort order to null
  -- Krushnakant TODO: What else should we nullify?
  return z
end
return require('Q/q_export').export('cat', cat)
