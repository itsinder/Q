local cmem	= require 'libcmem'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local Scalar = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'

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

  assert(is_base_qtype(qtype))
  if ( by ) then
    by = assert(to_scalar(by, qtype))
  else
    by = Scalar.new(1, qtype)
  end
  start = assert(to_scalar(start, qtype) )
  --==================================
  if ( type(len) == "Scalar" ) then len = len:to_num() end
  assert(type(len) == "number")
  assert(len > 0, "vector length must be positive")
  local subs = {};
  --========================
  -- Set c_mem using info from args
  local sz_c_mem = ffi.sizeof("SEQ_" .. qtype .. "_REC_TYPE")
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast("SEQ_" .. qtype .. "_REC_TYPE *", get_ptr(c_mem))
  c_mem_ptr.by    = ffi.cast(ctype .. " *", get_ptr(by:to_cmem()))[0]
  c_mem_ptr.start = ffi.cast(ctype .. " *", get_ptr(start:to_cmem()))[0]

  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/lua/seq.tmpl"
  local subs = {};
  subs.fn        = "seq_" .. qtype
  subs.c_mem     = c_mem
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.len       = len
  subs.out_qtype = qtype
  subs.c_mem_type = "SEQ_" .. qtype .. "_REC_TYPE *"
  return subs, tmpl
end
