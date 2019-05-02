local Q       = require 'Q/q_export'
local qc = require 'Q/UTILS/lua/q_core'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/lua/lVector'
local function SC_to_I4(
  inv, 
  dict
  )
  assert(type(inv) == "lVector")
  assert(type(dict) == "table")
  assert(inv:fldtype() == "SC")
  assert(inv:has_nulls() == false)

  local out_qtype = "I4"
  local out_ctype = qconsts.qtypes.out_qtype.ctype
  local out_width = qconsts.qtypes.out_qtype.width
  local in_width = inv:width()
  local out_buf = ffi.cast(out_ctype .. "  *",
    cmem.new(qconsts.chunk_size * out_width))
  local first_call = false
  local chunk_idx = 0
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    local len, base_data = inv:chunk(chunk_idx)
    base_data = ffi.cast("char *", base_data)
    local out_len = 0
    while len > 0  do
      in_str = ffi.string(base_data, in_width-1)
      local out_id = dict[in_str]
      if ( not out_id ) then
        out_id = 0
      else
        assert( ( type(out_id) == "number") and (out_id > 0 ))
      end
      out_buf[out_len] = out_id
      out_len   = out_len   + 1
      base_data = base_data + in_width
    end
    assert(out_len == len)
    return out_len, out_buf
  end
  local outv = lVector({qtype = qtype, gen = true, has_nulls = false})
  return outv
end
return require('Q/q_export').export('SC_to_I4', SC_to_I4)
