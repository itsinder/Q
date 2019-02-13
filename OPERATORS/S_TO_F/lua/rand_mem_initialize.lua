local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function mem_initialize(subs)
  if subs.out_qtype == "B1" then
    local mem_initialize = require 'Q/OPERATORS/S_TO_F/lua/rand_mem_initialize_B1'
    local status, c_mem_ptr_B1 = pcall(mem_initialize, subs)
    if status then
      return c_mem_ptr_B1
    else
      print(c_mem_ptr_B1)
      return
    end
  end

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
  local rec_type = "RAND_" .. subs.out_qtype .. "_REC_TYPE"
  local sz_c_mem = ffi.sizeof(rec_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(rec_type .. " *", get_ptr(c_mem))
  c_mem_ptr.lb = ffi.cast(subs.out_ctype .. " *", get_ptr(subs.lb:to_cmem()))[0]
  c_mem_ptr.ub = ffi.cast(subs.out_ctype .. " *", get_ptr(subs.ub:to_cmem()))[0]
  c_mem_ptr.seed = subs.seed

  return c_mem_ptr
end

return mem_initialize
