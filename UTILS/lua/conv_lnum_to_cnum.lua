return function (x, out_qtype)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local qc = require 'Q/UTILS/lua/q_core'
  local ffi = require 'Q/UTILS/lua/q_ffi'

  assert(type(out_qtype) == "string")
  local out_ctype = assert(qconsts.qtypes[out_qtype].ctype)

  if ( type(x) == "number" ) then 
    return ffi.new(out_ctype .. "[?]", 1, { x } )
  end

  assert(type(x) == "string", "type = " .. type(x) )
  local conv_fn_name = "txt_to_" .. out_qtype
  local width = assert(qconsts.qtypes[out_qtype].width)
  local c_mem = assert(ffi.malloc(width), "malloc failed")
  local conv_fn = assert(qc[conv_fn_name], "No converter")
  local status = conv_fn(x, c_mem)
  assert(status == 0, 
  "Unable to convert " .. scalar_val .. " to qtype" )
  return c_mem
end
