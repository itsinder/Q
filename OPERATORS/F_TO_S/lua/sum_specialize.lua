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
    local tmpl = 'sum.tmpl'

    local subs = {}
    if ( qtype == "B1" ) then
      subs.fn = "sum_B1"
      subs.reduce_ctype = "uint64_t" 
      tmpl = nil
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "sum"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.initial_val = 0
      if ( ( subs.ctype == "I1" ) or ( subs.ctype == "I2" ) or 
        ( subs.ctype == "I4" ) or ( subs.ctype == "I8" ) ) then
        subs.reduce_ctype = "uint64_t" 
      else
        subs.reduce_ctype = "double" 
      end
      subs.reducer = "mcr_nop"
      subs.t_reducer = "mcr_sum"
    end
    -- Set c_mem 
    hdr = string.gsub(hdr,"<<qtype>>", qtype)
    hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
    pcall(ffi.cdef, hdr)
    local sz_c_mem = ffi.sizeof("REDUCE_sum_" .. qtype .. "_ARGS")
    local c_mem = assert(ffi.malloc(sz_c_mem), "malloc failed")
    c_mem = ffi.cast("REDUCE_sum_" .. qtype .. "_ARGS *", c_mem)
    c_mem.sum_val  = 0
    c_mem.num = 0
    subs.c_mem = c_mem
    --==============================
    subs.getter = function (x) return x[0].sum_val, x[0].num end
    return subs, tmpl
end
