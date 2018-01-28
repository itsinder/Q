local function cat(X)
  local lVector     = require 'Q/RUNTIME/lua/lVector'
  local base_qtype  = require 'Q/UTILS/lua/is_base_qtype'
  local qconsts     = require 'Q/UTILS/lua/q_consts'
  local ffi         = require 'Q/UTILS/lua/q_ffi'
  
  assert(X and type(X) == "table", "X must be a table")
  local idx = 1
  local fldtype 
  local has_nulls
  for k, x in pairs(X) do 
    assert(type(x) == "lVector", "each element of x must be a vector")
    if ( idx == 1 ) then
      fldtype   = x:fldtype()
      has_nulls = x:has_nulls()
    else
      assert(x:fldtype() == fldtype, "all vectors must have same type")
      assert(x:has_nulls() == has_nulls "all vectors must have nulls or none must have nulls. We will relax this assumption later")
    end
    idx = idx + 1
  end

  -- Create output vector
  local qtype = x:fldtype()
  local width = qconsts.qtypes[x:fldtype()].width
  local chunk_size = qconsts.chunk_size

  local z_buf_size = chunk_size * width
  local z_buf = ffi.malloc(z_buf_size)
  ffi.fill(z_buf, z_buf_size)

  local z_nn_buf_size 
  local z_nn_buf 
  if ( has_nulls ) then 
    z_nn_buf_size = chunk_size
    z_nn_buf = ffi.malloc(z_nn_buf_size)
    ffi.fill(z_nn_buf, z_nn_buf_size)
  end

  local chunk_idx = 0
  
  -- Create z vector
  local z = lVector({qtype = qtype, gen = true, has_nulls = x:has_nulls()})
  for k, x in pairs(X) do 
    -- Process input vector x
    repeat
      local len, base_data, nn_data = x:chunk(chunk_idx)
      if len > 0 then
        -- Can't use base_data directly for put_chunk since not of type CMEM
        if qtype == "B1" then
          ffi.copy(z_buf, base_data, width * math.ceil(len / 8))
        else
          ffi.copy(z_buf, base_data, width * len)
          if nn_data then
            ffi.copy(z_nn_buf, nn_data, width * math.ceil(len / 8))
          end
        end
        z:put_chunk(z_buf, z_nn_buf, len)
        ffi.fill(z_buf, z_buf_size)
        ffi.fill(z_nn_buf, z_nn_buf_size)
      end
      chunk_idx = chunk_idx + 1
    until(len ~= chunk_size)
  end
  
  -- Initialize chunk_idx to zero
  chunk_idx = 0
  
  -- Process Y vector
  repeat
    local len, base_data, nn_data = y:chunk(chunk_idx)
    if len > 0 then
      if qtype == "B1" then
        ffi.copy(z_buf, base_data, width * math.ceil(len / 8))
      else
        ffi.copy(z_buf, base_data, width * len)
        if nn_data then
          ffi.copy(z_nn_buf, nn_data, width * math.ceil(len / 8))
        end
      end
      z:put_chunk(z_buf, z_nn_buf, len)
      ffi.fill(z_buf, z_buf_size)
      ffi.fill(z_nn_buf, z_nn_buf_size)
    end
    chunk_idx = chunk_idx + 1
  until(len ~= chunk_size)  
  
  -- EOV the output vector 
  z:eov()
  return z
end
return require('Q/q_export').export('cat', cat)
