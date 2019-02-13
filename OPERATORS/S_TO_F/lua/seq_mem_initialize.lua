local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function mem_initialize(subs)
  local hdr = [[
    typedef struct _seq_<<qtype>>_rec_type {
      <<ctype>> start;
      <<ctype>> by;
    } SEQ_<<qtype>>_REC_TYPE;
  ]]

  hdr = string.gsub(hdr,"<<qtype>>", subs.out_qtype)
  hdr = string.gsub(hdr,"<<ctype>>",  subs.out_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem using info from args
  local rec_type = "SEQ_" .. subs.out_qtype .. "_REC_TYPE"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(rec_type .. " *", get_ptr(c_mem))
  c_mem_ptr.by = ffi.cast(subs.out_ctype .. " *", get_ptr(subs.by:to_cmem()))[0]
  c_mem_ptr.start = ffi.cast(subs.out_ctype .. " *", get_ptr(subs.start:to_cmem()))[0]

  return c_mem_ptr
end

return mem_initialize
