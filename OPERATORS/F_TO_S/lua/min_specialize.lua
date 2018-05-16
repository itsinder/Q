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
typedef struct _reduce_min_<<qtype>>_args {
  <<reduce_ctype>> min_val;
  uint64_t num; // number of non-null elements inspected
  int64_t min_index;
} REDUCE_min_<<qtype>>_ARGS;
  ]]
    
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( qtype == "B1" ) then
      subs.reduce_qtype = "I1"
      assert(nil, "TODO")
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "min"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype
      subs.reduce_qtype = qtype
      subs.reducer_struct_type = "REDUCE_min_" .. qtype .. "_ARGS"

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
      subs.reducer   = "mcr_min"
      subs.t_reducer = "mcr_min"
      --==============================
      -- Set c_mem using info from args
      local sz_c_mem = ffi.sizeof("REDUCE_min_" .. qtype .. "_ARGS")
      local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
      local c_mem_ptr = ffi.cast("REDUCE_min_" .. qtype .. "_ARGS *", get_ptr(c_mem))
      c_mem_ptr.min_val  = qconsts.qtypes[qtype].max
      c_mem_ptr.num = 0
      c_mem_ptr.min_index = -1
      subs.c_mem = c_mem
      subs.c_mem_type = "REDUCE_min_" .. qtype .. "_ARGS *"
    --==============================
      subs.getter = function (x) 
        local y = ffi.cast("REDUCE_min_" .. qtype .. "_ARGS *", get_ptr(c_mem))
        return Scalar.new(x, subs.reduce_qtype), 
           Scalar.new(tonumber(y[0].num), "I8"), Scalar.new(tonumber(y[0].min_index), "I8")
      end
    --==============================
    end
    return subs, tmpl
end
