local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Scalar  = require 'libsclr'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
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
      subs.reduce_qtype = "I1"
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "max"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype
      subs.reduce_qtype = qtype
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
      local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
      local c_mem_ptr = ffi.cast("REDUCE_max_" .. qtype .. "_ARGS *", get_ptr(c_mem))
      c_mem_ptr.max_val  = qconsts.qtypes[qtype].min
      c_mem_ptr.num = 0
      subs.c_mem = c_mem
    --==============================
      subs.getter = function (x) 
      local y = ffi.cast("REDUCE_max_" .. qtype .. "_ARGS *", get_ptr(c_mem))
        return Scalar.new(x, subs.reduce_qtype), 
           Scalar.new(tonumber(y[0].num), "I8")
      end
    --==============================
    end
    return subs, tmpl
end
