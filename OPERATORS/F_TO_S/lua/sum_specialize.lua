local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
return function (
  qtype
  )
  local hdr = [[
typedef struct _reduce_sum_<<qtype>>_args {
  <<reduce_ctype>> sum_val;
  uint64_t num; // number of non-null elements inspected
} REDUCE_sum_<<qtype>>_ARGS;
  ]]
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( qtype == "B1" ) then
      subs.fn = "sum_B1"
      tmpl = nil
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "sum"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.initial_val = 0
      if ( ( ctype == "I1" ) or ( ctype == "I2" ) or 
           ( ctype == "I4" ) or ( ctype == "I8" ) ) then
        subs.reduce_ctype = "uint64_t" 
      else
        subs.reduce_ctype = "double" 
      end
      hdr = string.gsub(hdr,"<<qtype>>", qtype)
      hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
      pcall(ffi.cdef, hdr)
      subs.reducer = "mcr_sum"
      subs.t_reducer = subs.reducer
      --==============================
      -- Set c_mem using info from args
      local sz_c_mem = ffi.sizeof("REDUCE_sum_" .. qtype .. "_ARGS")
      local c_mem = assert(ffi.malloc(sz_c_mem), "malloc failed")
      c_mem = ffi.cast("REDUCE_sum_" .. qtype .. "_ARGS *", c_mem)
      c_mem.sum_val  = 0
      c_mem.num = 0
      subs.c_mem = c_mem
      --==============================
      subs.getter = function (x) return x[0].sum_val, x[0].num end
    end
    return subs, tmpl
end
