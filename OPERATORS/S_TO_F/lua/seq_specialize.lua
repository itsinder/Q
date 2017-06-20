return function (
  args
  )
  local qconsts = require "Q/UTILS/lua/q_consts"
  local qc = require "Q/UTILS/lua/q_core"
  local ffi = require "Q/UTILS/lua/q_ffi"
  local hdr = [[
  typedef struct _seq_<<qtype>>_rec_type {
    <<ctype>> start;
    <<ctype>> by;
  } SEQ_<<qtype>>_REC_TYPE;
]]
  assert(type(args) == "table")
  local start  = assert(args.start)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local by = args.by

  hdr = string.gsub(hdr, "<<qtype>>", qtype)
  hdr = string.gsub(hdr, "<<ctype>>", qconsts.qtypes[qtype].ctype)

  pcall(ffi.cdef, hdr)

  if ( by ) then
    assert(type(by) == "number")
  else
    by = 1
  end
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  assert(type(start) == "number")

  local subs = {};
  --========================
  -- Set c_mem using info from args
  local sz_c_mem = ffi.sizeof("SEQ_" .. qtype .. "_REC_TYPE")
  local c_mem = assert(qc.malloc(sz_c_mem), "malloc failed")
  c_mem = ffi.cast("SEQ_" .. qtype .. "_REC_TYPE *", c_mem)
  c_mem.start = start
  c_mem.by = by
  --========================
  local tmpl = 'seq.tmpl'
  local subs = {};
  subs.fn = "seq_" .. qtype
  subs.c_mem = c_mem
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.len = len
  subs.out_qtype = qtype
  return subs, tmpl
end
