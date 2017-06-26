return function (
  args
  )
  local qc      = require "Q/UTILS/lua/q_core"
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local conv_lnum_to_cnum = require 'Q/UTILS/lua/conv_lnum_to_cnum'
  local is_base_qtype     = require 'Q/UTILS/lua/is_base_qtype'

  assert(type(args) == "table")
  local val   = assert(args.val)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  assert(is_base_qtype(qtype))
  assert(type(len) == "number")
  assert(len > 0, "vector length must be positive")
  assert((type(val) == "number") or ( type(val) == "string"))
  local tmpl = 'const.tmpl'
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.c_mem = assert(conv_lnum_to_cnum(val, qtype))
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.len = len
  subs.out_qtype = qtype
  return subs, tmpl
end
