local ffi           = require 'Q/UTILS/lua/q_ffi'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'

local function flush_buffers(
  cols, 
  M, 
  out_bufs, 
  nn_out_bufs, 
  n_buf
  )
  print("Intermediate Flush ..")
  for i = 1, #M do
    if ( M[i].is_load ) then 
      -- write to column
      cols[i]:put_chunk(out_bufs[i], nn_out_bufs[i], n_buf)
      -- Initialize buffer to 0
      local qtype = assert(M[i].qtype)
      local width = 0
      if ( qtype == "SC" ) then 
        width = assert(M.width)
      else
        width = assert(qconsts.qtypes[qtype].width)
      end
      assert(width > 0)
      ffi.fill(out_bufs[i], n_buf * width)
      if ( M[i].has_nulls ) then 
        ffi.fill(nn_out_bufs[i], n_buf / 8)
      end
    end
  end
 end
return flush_buffers
