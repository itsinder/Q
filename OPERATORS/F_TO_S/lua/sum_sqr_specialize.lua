local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')

return function (
  qtype
  )
  local hdr = [[
typedef struct _reduce_sum_sqr_<<qtype>>_args {
  <<reduce_ctype>> sum_sqr_val;
  uint64_t num; // number of non-null elements inspected
} REDUCE_sum_sqr_<<qtype>>_ARGS;
  ]]
    local tmpl = 'sum.tmpl'
    local subs = {}
    assert(is_base_qtype(qtype), "qtype must be base type, not" .. qtype) 
    subs.op = "sum_sqr" 
    subs.fn = subs.op .. "_" .. qtype 
    subs.ctype = qconsts.qtypes[qtype].ctype
    subs.qtype = qtype
    subs.initial_val = 0
    if ( ( qtype == "I1" ) or ( qtype == "I2" ) or 
         ( qtype == "I4" ) or ( qtype == "I8" ) ) then
      subs.reduce_ctype = "uint64_t" 
    elseif ( ( qtype == "F4" ) or ( qtype == "F8" ) ) then
      subs.reduce_ctype = "double"
    else
      assert(nil, "Invalid qtype " .. qtype)
    end
    hdr = string.gsub(hdr,"<<qtype>>", qtype)
    hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
    pcall(ffi.cdef, hdr)
    subs.reducer = "mcr_sqr"
    subs.t_reducer = "mcr_sum"
    --==============================
    -- Set c_mem using info from args
    local sz_c_mem = ffi.sizeof("REDUCE_sum_sqr_" .. qtype .. "_ARGS")
    local c_mem = assert(ffi.malloc(sz_c_mem), "malloc failed")
    c_mem = ffi.cast("REDUCE_sum_sqr_" .. qtype .. "_ARGS *", c_mem)
    c_mem.sum_sqr_val  = 0
    c_mem.num = 0
    subs.c_mem = c_mem
    --==============================
    subs.getter = function (x) return x[0].sum_sqr_val, x[0].num end
    return subs, tmpl
end
