local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Scalar  = require 'libsclr'

local function mink_specialize(fldtype)

  local hdr = [[
  typedef struct _reduce_mink_<<qtype>>_args {
  <<reduce_ctype>> *val; // [k]
  <<reduce_ctype>> *drag; // [k]
  uint64_t n; // actual occupancy
  uint64_t k; // max occupancy
  } REDUCE_mink_<<qtype>>_ARGS;
  ]]

  if ( qtype == "B1" ) then
    assert(nil, "TODO")
  end

  local subs = {}

  local qtype = fldtype
  local ctype = qconsts.qtypes[qtype].ctype
  local width = qconsts.qtypes[qtype].width
  local struct_type = "REDUCE_mink_" .. qtype .. "_ARGS"

  subs.qtype = qtype
  subs.ctype = ctype
  subs.width = width
  subs.reduce_ctype = ctype
  subs.reduce_qtype = qtype
  subs.reducer_struct_type = struct_type

  hdr = string.gsub(hdr,"<<qtype>>", qtype)
  hdr = string.gsub(hdr,"<<reduce_ctype>>",  subs.reduce_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem
  local sz_c_mem = ffi.sizeof(struct_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  -- c_mem initialization will happen in expander as we are not aware of value of k here
  subs.c_mem = c_mem
  subs.c_mem_type = "REDUCE_mink_" .. qtype .. "_ARGS *"

  local tmpl = "getk.tmpl"
  subs.fn = "mink_" .. qtype
  subs.comparator = "<"
  subs.op = "mink"

  subs.getter = function (x)
    local y = ffi.cast(struct_type .. " *", get_ptr(c_mem))
    local vals = {}
    local drag = {}
    for i = 0, tonumber(y[0].n)-1 do
      vals[#vals+1] = Scalar.new(y[0].val[i], qtype)
      drag[#drag+1] = Scalar.new(y[0].drag[i], qtype)
    end
    return vals, drag
  end
  
  return subs, tmpl
end
return mink_specialize
