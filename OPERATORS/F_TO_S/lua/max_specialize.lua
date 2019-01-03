local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Scalar  = require 'libsclr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'

return function (
  qtype
  )
  local hdr = [[
typedef struct _reduce_max_<<qtype>>_args {
  <<reduce_ctype>> max_val;
  uint64_t num; // number of non-null elements inspected
  int64_t max_index;
} REDUCE_max_<<qtype>>_ARGS;
  ]]
    local tmpl = qconsts.q_src_root .. "/OPERATORS/F_TO_S/lua/reduce.tmpl"
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
      -- Updated the initial val for F4 and F8
      -- FLT_MIN and DBL_MIN have minimum, normalized, positive value of float and double
      -- so for negative values in input vector, these are not appropriate initial values
      if ( qtype == "F4" ) then subs.initial_val = "-FLT_MAX-1" end
      if ( qtype == "F8" ) then subs.initial_val = "-DBL_MAX-1" end
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
      c_mem_ptr.max_index = -1
      subs.c_mem = c_mem
      subs.c_mem_type = "REDUCE_max_" .. qtype .. "_ARGS *"
    --==============================
      subs.getter = function (x) 
        local y = ffi.cast("REDUCE_max_" .. qtype .. "_ARGS *", get_ptr(c_mem))
        return Scalar.new(x, subs.reduce_qtype), 
          Scalar.new(tonumber(y[0].num), "I8"), Scalar.new(tonumber(y[0].max_index), "I8")
      end
    --==============================
    end
    return subs, tmpl
end
