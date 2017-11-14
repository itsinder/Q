local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Scalar  = require 'libsclr'
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
      local c_mem = assert(ffi.malloc(sz_c_mem), "malloc failed")
      local bak_c_mem = c_mem
      c_mem = ffi.cast("REDUCE_min_" .. qtype .. "_ARGS *", c_mem)
      c_mem.min_val  = qconsts.qtypes[qtype].max
      c_mem.num = 0
      subs.c_mem = bak_c_mem
    --==============================
      subs.getter = function (x) 
        local y = ffi.cast("REDUCE_min_" .. qtype .. "_ARGS *", c_mem)
        print("XXX ", y[0].min_val, y[0].num)
        return Scalar.new(x, subs.reduce_qtype), 
           Scalar.new(tonumber(y[0].num), "I8")
      end
    --==============================
    end
    return subs, tmpl
end
