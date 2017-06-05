return function (
  args
  )
  local qc = require "Q/UTILS/lua/q_core"

  assert(type(args) == "table")
  local val   = assert(args.val)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  assert((type(val) == "number") or ( type(val) == "string"))
  local conv_fn = "txt_to_" .. qtype
  local out_ctype = g_qtypes[qtype].ctype
  local width = g_qtypes[qtype].width
  local c_mem = assert(qc.malloc(width), "malloc failed")
  qc.fill(c_mem, width, 0)
  local conv_fn = qc["txt_to_" .. qtype]
  local status = nil
  if ( g_iorf[qtype] == "fixed" ) then 
    status = conv_fn(tostring(val), 10, c_mem)
  elseif ( g_iorf[qtype] == "floating_point" ) then 
    status  = conv_fn(tostring(val), c_mem)
  else
    assert(nil, "Unknown type " .. qtype)
  end
  -- local x = ffi.cast(out_ctype .. " *", c_mem); print(x[0])
  assert(status, "Unable to convert to scalar " .. args.val)
  local tmpl = 'const.tmpl'
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.c_mem = c_mem
  subs.out_ctype = out_ctype
  subs.len = len
  subs.out_qtype = qtype
  return subs, tmpl
end
