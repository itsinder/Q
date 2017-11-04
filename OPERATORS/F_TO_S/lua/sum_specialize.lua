local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local Scalar  = require 'libsclr'
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
    subs.macro = "mcr_nop"
    if ( qtype == "B1" ) then
      subs.fn = "sum_B1"
      subs.reduce_ctype = "uint64_t" 
      subs.reduce_qtype = "I8" 
      tmpl = nil
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "sum"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.initial_val = 0
      if ( ( subs.qtype == "I1" ) or ( subs.qtype == "I2" ) or 
        ( subs.qtype == "I4" ) or ( subs.qtype == "I8" ) ) then
        subs.reduce_ctype = "int64_t" 
        subs.reduce_qtype = "I8" 
      elseif ( ( subs.qtype == "F4" ) or ( subs.qtype == "F8" ) ) then
        subs.reduce_ctype = "double" 
        subs.reduce_qtype = "F8" 
      else
        assert(nil)
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
    local bak_c_mem = c_mem
    c_mem = ffi.cast("REDUCE_sum_" .. qtype .. "_ARGS *", c_mem)
    c_mem.sum_val  = 0
    c_mem.num = 0
    subs.c_mem = bak_c_mem
    --==============================
    subs.getter = function (x) 
    -- return Scalar.new(tonumber(x[0].sum_val), subs.reduce_qtype), 
      local y = ffi.cast("REDUCE_sum_" .. qtype .. "_ARGS *", c_mem)
      return Scalar.new(x, subs.reduce_qtype), 
           Scalar.new(tonumber(y[0].num), "I8")
    end
    return subs, tmpl
end
