local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Scalar  = require 'libsclr'

local function mink_specialize(val_fldtype, drag_fldtype)

  local hdr = [[
  typedef struct _reduce_mink_<<v_qtype>>_<<d_qtype>>_args {
  <<reduce_v_ctype>> *val; // [k]
  <<reduce_d_ctype>> *drag; // [k]
  uint64_t n; // actual occupancy
  uint64_t k; // max occupancy
  } REDUCE_mink_<<v_qtype>>_<<d_qtype>>_ARGS;
  ]]

  if ( val_fldtype == "B1" ) then
    assert(nil, "TODO")
  end

  local subs = {}

  local v_qtype = val_fldtype
  local v_ctype = qconsts.qtypes[v_qtype].ctype
  local v_width = qconsts.qtypes[v_qtype].width

  local d_qtype = drag_fldtype
  local d_ctype = qconsts.qtypes[d_qtype].ctype
  local d_width = qconsts.qtypes[d_qtype].width

  local struct_type = "REDUCE_mink_" .. v_qtype .. "_" .. d_qtype .. "_ARGS"
  subs.v_qtype = v_qtype
  subs.v_ctype = v_ctype
  subs.v_width = v_width
  subs.reduce_v_ctype = v_ctype
  subs.reduce_v_qtype = v_qtype
  subs.reducer_struct_type = struct_type

  subs.d_qtype = d_qtype
  subs.d_ctype = d_ctype
  subs.d_width = d_width
  subs.reduce_d_ctype = d_ctype
  subs.reduce_d_qtype = d_qtype


  hdr = string.gsub(hdr,"<<v_qtype>>", v_qtype)
  hdr = string.gsub(hdr,"<<d_qtype>>", d_qtype)
  hdr = string.gsub(hdr,"<<reduce_v_ctype>>",  subs.reduce_v_ctype)
  hdr = string.gsub(hdr,"<<reduce_d_ctype>>",  subs.reduce_d_ctype)
  pcall(ffi.cdef, hdr)

  -- Set c_mem
  local sz_c_mem = ffi.sizeof(struct_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  -- c_mem initialization will happen in expander as we are not aware of value of k here
  subs.c_mem = c_mem
  subs.c_mem_type = "REDUCE_mink_" .. v_qtype .. "_" .. d_qtype .. "_ARGS *"

  local tmpl = "getk.tmpl"
  subs.fn = "mink_" .. v_qtype .. "_" .. d_qtype
  subs.comparator = "<"
  subs.op = "mink"

  subs.getter = function (x)
    local y = ffi.cast(struct_type .. " *", get_ptr(c_mem))
    local vals = {}
    local drag = {}
    for i = 0, tonumber(y[0].n)-1 do
      vals[#vals+1] = Scalar.new(y[0].val[i], v_qtype)
      drag[#drag+1] = Scalar.new(y[0].drag[i], d_qtype)
    end
    return vals, drag
  end
  
  return subs, tmpl
end
return mink_specialize
