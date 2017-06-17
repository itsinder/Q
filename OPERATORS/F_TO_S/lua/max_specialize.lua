local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
return function (
  qtype
  )
  local hdr = [[
typedef struct _reduce_max_<<qtype>>_args {
  <<reduce_ctype>> max_val;
  uint64_t num; // number of non-null elements inspected
} REDUCE_max_<<qtype>>_ARGS;
  ]]
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( qtype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "max"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype
      hdr = string.gsub(hdr,"<<qtype>>", qtype)
      hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
      pcall(ffi.cdef, hdr)
      if ( qtype == "I1" ) then subs.initial_val = "INT8_MIN" end
      if ( qtype == "I2" ) then subs.initial_val = "INT16_MIN" end
      if ( qtype == "I4" ) then subs.initial_val = "INT32_MIN" end
      if ( qtype == "I8" ) then subs.initial_val = "INT64_MIN" end
      if ( qtype == "F4" ) then subs.initial_val = "FLT_MIN" end
      if ( qtype == "F8" ) then subs.initial_val = "DBL_MIN" end
      assert(subs.initial_val)
      subs.reducer = "mcr_max"
      subs.t_reducer = subs.reducer
      --==============================
      -- Set c_mem using info from args
      local sz_c_mem = ffi.sizeof("REDUCE_max_" .. qtype .. "_ARGS")
      local c_mem = assert(ffi.malloc(sz_c_mem), "malloc failed")
      c_mem = ffi.cast("REDUCE_max_" .. qtype .. "_ARGS *", c_mem)
      c_mem.max_val  = qconsts.qtypes[qtype].min
      c_mem.num = 0
      subs.c_mem = c_mem
      --==============================
      subs.getter = function (x) return x[0].max_val, x[0].num end
    end
    return subs, tmpl
end
