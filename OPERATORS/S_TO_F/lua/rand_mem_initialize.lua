local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function mem_initialize(subs)
  local hdr = [[
    typedef struct _rand_<<qtype>>_rec_type {
      uint64_t seed;
      <<ctype>> lb;
      <<ctype>> ub;
      struct drand48_data buffer;
    } RAND_<<qtype>>_REC_TYPE;
  ]]
  hdr = string.gsub(hdr,"<<qtype>>", subs.out_qtype)
  hdr = string.gsub(hdr,"<<ctype>>",  subs.out_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local sz_c_mem = ffi.sizeof("RAND_" .. subs.out_qtype .. "_REC_TYPE")
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast("RAND_" .. subs.out_qtype .. "_REC_TYPE *", get_ptr(c_mem))
  c_mem_ptr.lb = ffi.cast(subs.out_ctype .. " *", get_ptr(subs.lb:to_cmem()))[0]
  c_mem_ptr.ub = ffi.cast(subs.out_ctype .. " *", get_ptr(subs.ub:to_cmem()))[0]
  c_mem_ptr.seed = subs.seed

  return c_mem_ptr
end

return mem_initialize
