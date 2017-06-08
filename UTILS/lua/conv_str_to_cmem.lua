return function (x, out_qtype)
  q_consts = require 'Q/UTILS/lua/q_const'
  local qc = require 'Q/UTILS/lua/q_core'
  local ffi = require 'Q/UTILS/lua/q_ffi'
  if ( type(x) == "number" ) then x = tostring(x) end 
  assert(type(x) == "string")
  assert(type(out_qtype) == "string")
  local out_ctype = assert(g_qtypes[out_qtype].ctype)
  local conv_fn_name = "txt_to_" .. out_qtype
  local width = assert(qconsts.qtypes[out_qtype].width)
  local c_mem = assert(ffi.malloc(width), "malloc failed")
  c_mem = ffi.cast(out_ctype .. " *", c_mem)
  local conv_fn = assert(qc[conv_fn_name], "No converter")
  print(conv_fn_name)
  local status = conv_fn(x, c_mem)
  assert(status, "Unable to convert " .. scalar_val .. " to qtype" )
  return c_mem
end
