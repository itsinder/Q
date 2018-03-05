local cmem	= require 'libcmem'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
return function (
  args
  )
  local qconsts = require "Q/UTILS/lua/q_consts"
  local qc = require "Q/UTILS/lua/q_core"
  local ffi = require "Q/UTILS/lua/q_ffi"
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  --====================================
  local hdr = [[
  typedef struct _seq_<<qtype>>_rec_type {
    <<ctype>> start;
    <<ctype>> by;
  } SEQ_<<qtype>>_REC_TYPE;
]]
  assert(type(args) == "table")
  local start = assert(args.start)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local by    = args.by
  local ctype = assert(qconsts.qtypes[qtype].ctype)

  hdr = string.gsub(hdr, "<<qtype>>", qtype)
  hdr = string.gsub(hdr, "<<ctype>>", ctype)
  pcall(ffi.cdef, hdr)

  local by_ptr = get_ptr(cmem.new(ffi.sizeof(ctype)), qtype)
  assert(is_base_qtype(qtype))
  if ( by ) then
    by_ptr[0] = by
  else
    by_ptr[0] = 1
  end
  local start_ptr = get_ptr(cmem.new(ffi.sizeof(ctype)), qtype)
  start_ptr[0] = start
  --==================================
  assert(type(len) == "number")
  assert(len > 0, "vector length must be positive")
  local subs = {};
  --========================
  -- Set c_mem using info from args
  local sz_c_mem = ffi.sizeof("SEQ_" .. qtype .. "_REC_TYPE")
  local c_mem = assert(get_ptr(cmem.new(sz_c_mem)), "malloc failed")
  c_mem = ffi.cast("SEQ_" .. qtype .. "_REC_TYPE *", c_mem)
  c_mem.by    = ffi.cast(ctype .. " *", by_ptr)[0]
  c_mem.start = ffi.cast(ctype .. " *", start_ptr)[0]

  local tmpl = 'seq.tmpl'
  local subs = {};
  subs.fn        = "seq_" .. qtype
  subs.c_mem     = c_mem
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.len       = len
  subs.out_qtype = qtype
  return subs, tmpl
end
