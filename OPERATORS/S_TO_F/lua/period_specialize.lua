local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
return function (
  args
  )
  local qc  = require "Q/UTILS/lua/q_core"
  local ffi = require "Q/UTILS/lua/q_ffi"
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  --============================
  assert(type(args) == "table")
  local start = assert(args.start)
  local period = assert(args.period)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local by    = args.by
  if ( not by ) then by = 1 end
  assert(is_base_qtype(qtype))
  assert(type(len) == "number")
  assert(len > 0, "vector length must be positive")
  assert(type(start) == "number")
  assert(type(period) == "number")
  assert(period > 1, "length of period must be > 1") 
  assert(type(by) == "number")

  local hdr = [[
  typedef struct _period_<<qtype>>_rec_type {
    <<ctype>> start;
    <<ctype>> by;
   int period;
  } PERIOD_<<qtype>>_REC_TYPE;
]]

  hdr = string.gsub(hdr, "<<qtype>>", qtype)
  hdr = string.gsub(hdr, "<<ctype>>", qconsts.qtypes[qtype].ctype)
  pcall(ffi.cdef, hdr)

  local out_ctype = qconsts.qtypes[qtype].ctype
  local rec_type = 'PERIOD_' .. qtype .. '_REC_TYPE';
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(qc.malloc(sz_c_mem), "malloc failed")
  local x = ffi.cast(rec_type .. " *", c_mem); 
  x.start  = args.start;
  x.by     = args.by;
  x.period = args.period;
  local tmpl = 'period.tmpl'
  local subs = {};
  subs.fn          = "period_" .. qtype
  subs.c_mem       = c_mem
  subs.out_ctype   = out_ctype
  subs.len         = len
  subs.out_qtype   = qtype
  return subs, tmpl
end
