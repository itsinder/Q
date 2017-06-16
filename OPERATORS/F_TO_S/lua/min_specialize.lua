local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')

return function (
  qtype
  )
  local hdr = [[
typedef struct _reduce_min_<<qtype>>_args {
  <<reduce_ctype>> min_val;
  uint64_t num; // number of non-null elements inspected
} REDUCE_min_<<qtype>>_ARGS;
  ]]
    
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( qtype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "min"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype

      hdr = string.gsub(hdr,"<<qtype>>", qtype)
      hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
      pcall(ffi.cdef, hdr)

      if ( qtype == "I1" ) then subs.initial_val = "INT8_MAX" end
      if ( qtype == "I2" ) then subs.initial_val = "INT16_MAX" end
      if ( qtype == "I4" ) then subs.initial_val = "INT32_MAX" end
      if ( qtype == "I8" ) then subs.initial_val = "INT64_MAX" end
      if ( qtype == "F4" ) then subs.initial_val = "FLT_MAX" end
      if ( qtype == "F8" ) then subs.initial_val = "DBL_MAX" end
      assert(subs.initial_val)
      --==============================
      -- Set c_mem using info from args
      local sz_c_mem = ffi.sizeof("REDUCE_min_" .. qtype .. "_ARGS")
      local c_mem = assert(ffi.malloc(sz_c_mem), "malloc failed")
      c_mem = ffi.cast("REDUCE_min_" .. qtype .. "_ARGS *", c_mem)
      c_mem.min_val  = qconsts.qtypes[qtype].max
      c_mem.num = 0
      subs.c_mem = c_mem
      --==============================
      subs.reducer = "mcr_min"
      subs.t_reducer = subs.reducer
      subs.getter = function (x) return x[0].min_val, x[0].num end
    --==================
    end
    return subs, tmpl
end
