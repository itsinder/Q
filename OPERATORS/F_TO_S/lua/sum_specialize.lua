local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
return function (
  qtype
  )
    local hdr = [[
    typedef struct _reduce_sum_<<qtype>>_args {
      <<reduce_ctype>> sum_val;
      uint64_t num; // number of non-null elements inspected
    } REDUCE_sum_<<qtype>>_ARGS;
    ]]
    local tmpl = qconsts.q_src_root .. "/OPERATORS/F_TO_S/lua/sum.tmpl"

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
    local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
    local c_mem_ptr = ffi.cast("REDUCE_sum_" .. qtype .. "_ARGS *", get_ptr(c_mem))
    c_mem_ptr.sum_val  = 0
    c_mem_ptr.num = 0
    subs.c_mem = c_mem
    subs.c_mem_type = "REDUCE_sum_" .. qtype .. "_ARGS *"
    --==============================
    subs.getter = function (x)
      local y = ffi.cast("REDUCE_sum_" .. qtype .. "_ARGS *", get_ptr(c_mem))
      local z = ffi.cast("void *", y[0].num);
      -- TODO P2 I do not like the fact that I cannot send
      -- &(x[0].num) to Scalar.new for second Scalar call
      return Scalar.new(x, subs.reduce_qtype), 
           Scalar.new(tonumber(y[0].num), "I8")
    end
    --==============================
    return subs, tmpl
end
