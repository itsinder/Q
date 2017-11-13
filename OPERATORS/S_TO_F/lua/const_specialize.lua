local Scalar = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
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
  val = assert(to_scalar(val, qtype))
  local out_ctype = qconsts.qtypes[qtype].ctype

  --=======================
  local tmpl = 'const.tmpl'
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.c_mem = val:cdata()
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

