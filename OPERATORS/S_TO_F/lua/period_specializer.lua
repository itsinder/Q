return function (
  args
  )
  local qc = require "Q/UTILS/lua/q_core"

  assert(type(args) == "table")
  local start  = assert(args.start)
  local p_len  = assert(args.p_len)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local by = args.by
  if ( not by ) then by = 1 end
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  assert(type(start) == "number")
  assert(type(p_len) == "number")
  assert(p_len > 0, "length of period must be positive") 
  assert(type(by) == "number")
  local conv_fn = "txt_to_" .. qtype
  local out_ctype = g_qtypes[qtype].ctype
  local width = g_qtypes[qtype].width
  local c_mem = assert(qc.malloc(width), "malloc failed")
  qc.fill(c_mem, width, 0)
  local conv_fn = qc["txt_to_" .. qtype]
  local status 
  assert(status == 0, "Unable to create sequence vector ")
  --=========================
  -- local x = ffi.cast(out_ctype .. " *", c_mem); print(x[0])
  local tmpl = 'rand.tmpl'
  local subs = {};
  subs.fn = "rand_" .. qtype
  subs.c_mem = c_mem
  subs.out_ctype = out_ctype
  subs.len = len
  subs.p_len = p_len
  subs.out_qtype = qtype
  return subs, tmpl
end
