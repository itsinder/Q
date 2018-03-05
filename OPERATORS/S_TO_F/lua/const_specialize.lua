local cmem	= require 'libcmem'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'

return function (
  args
  )
  local qc      = require "Q/UTILS/lua/q_core"
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')

  assert(type(args) == "table")
  local val   = assert(args.val)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local out_ctype = qconsts.qtypes[qtype].ctype
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  local data_ptr = get_ptr(cmem.new(ffi.sizeof(out_ctype)), qtype)
  data_ptr[0] = val


  --=======================
  local tmpl = 'const.tmpl'
  local subs = {};
  subs.fn = "const_" .. qtype
  subs.c_mem = data_ptr
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

