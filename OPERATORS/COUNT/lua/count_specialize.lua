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
typedef struct _reduce_count_<<qtype>>_args {
  uint64_t count; // count of input value
} REDUCE_count_<<qtype>>_ARGS;
  ]]
    local tmpl = 'count.tmpl'
    local subs = {}
    if ( qtype == "B1" ) then
      assert(nil, "TODO")
      subs.reduce_qtype = "I1"
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "count"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype
      subs.reduce_qtype = qtype
      hdr = string.gsub(hdr,"<<qtype>>", qtype)
      hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
      pcall(ffi.cdef, hdr)

      --==============================
      -- Set c_mem using info from args
      local sz_c_mem = ffi.sizeof("REDUCE_count_" .. qtype .. "_ARGS")
      local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
      local c_mem_ptr = ffi.cast("REDUCE_count_" .. qtype .. "_ARGS *", get_ptr(c_mem))
      c_mem_ptr.count = 0
      subs.c_mem = c_mem
      subs.c_mem_type = "REDUCE_count_" .. qtype .. "_ARGS *"
    --==============================
      subs.getter = function (x) 
        local y = ffi.cast("REDUCE_count_" .. qtype .. "_ARGS *", get_ptr(c_mem))
        return Scalar.new(tonumber(y[0].count), "I8")
      end
    --==============================
    end
    return subs, tmpl
end
