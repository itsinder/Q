return function (
  args
  )
  local qc      = require "Q/UTILS/lua/q_core"
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local qconsts = require 'Q/UTILS/lua/q_consts'

  assert(type(args) == "table")
  local val   = assert(args.val)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  assert((type(val) == "number") or ( type(val) == "string"))
  local conv_fn = "txt_to_" .. qtype
  local out_ctype = qconsts.qtypes[qtype].ctype

  --=======================
  --[[
  local width = qconsts.qtypes[qtype].width
  local c_mem = assert(ffi.malloc(width), "malloc failed")
  print("ADDRESS = ", c_mem)
  ffi.fill(c_mem, width, 0)
  local conv_fn = assert(qc["txt_to_" .. qtype], "No converter function")
  local status = nil
  status = conv_fn(tostring(val), c_mem)
  assert(status, "Unable to convert to scalar " .. args.val)
  --]]

  local conv_lnum_to_cnum = require 'Q/UTILS/lua/conv_lnum_to_cnum'
  local c_mem = assert(conv_lnum_to_cnum(val, qtype))
  --=======================

  local tmpl = 'const.tmpl'
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.c_mem = c_mem
  subs.out_ctype = out_ctype
  subs.len = len
  if ( ( qtype == "F4" ) or ( subs.qtype == "F8" ) )  then 
    subs.format = "%llf"
  else
    subs.format = "%lld"
  end
  subs.out_qtype = qtype
  return subs, tmpl
end

