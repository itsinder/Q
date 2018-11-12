local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local Scalar  = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
return function (
  qtype,
  comparison,
  optargs
  )
    local tmpl
    local fast = false
    if ( optargs ) then 
      assert(type(optargs) == "table")
      if ( optargs.mode == "fast" ) then
        tmpl = 'par_is_next.tmpl'
        fast = true
      end
    end
    if ( not tmpl ) then tmpl = 'is_next.tmpl' end
    local subs = {}
    assert(is_base_qtype(qtype))
    if ( comparison == "gt" ) then
      subs.comparison_operator = " <= " 
    elseif ( comparison == "lt" ) then
      subs.comparison_operator = " >= " 
    elseif ( comparison == "geq" ) then
      subs.comparison_operator = " < " 
    elseif ( comparison == "leq" ) then
      subs.comparison_operator = " > " 
    elseif ( comparison == "eq" ) then
      subs.comparison_operator = " == " 
    elseif ( comparison == "neq" ) then
      subs.comparison_operator = " != " 
    else
      assert(nil, "invalid comparison" .. comparison)
    end
    subs.qtype = qtype
    subs.ctype = qconsts.qtypes[qtype].ctype
    -- Set c_mem 
    local rec_name = string.format("is_next_%s_%s_ARGS",
      comparison, qtype)
    if ( fast ) then rec_name = "par_" .. rec_name end 
    local hdr = string.format([[
    typedef struct _%s { 
     %s prev_val;
      int is_violation;
      int num_seen;
    } %s]], rec_name, subs.ctype, rec_name)
    pcall(ffi.cdef, hdr)
    local sz_c_mem = ffi.sizeof(rec_name)
    local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
    local c_mem_ptr = ffi.cast(rec_name .. " *", get_ptr(c_mem))
    c_mem_ptr.prev_val     = 0
    c_mem_ptr.is_violation = 0
    c_mem_ptr.num_seen = 0
    subs.c_mem = c_mem
    subs.rec_name = rec_name
    subs.c_mem_type = rec_name .. " *"
    if ( fast ) then 
      subs.fn = "par_is_next_" .. comparison .. "_" .. qtype
    else
      subs.fn = "is_next_" .. comparison .. "_" .. qtype
    end
    --==============================
    subs.getter = function (x) 
      local y = ffi.cast(rec_name .. " *", get_ptr(c_mem))
      local is_good
      if ( y[0].is_violation == 1 ) then 
        is_good = false
      else 
        is_good = true
      end
      local n = y[0].num_seen
      return is_good, tonumber(n)
    end
    --==============================
    return subs, tmpl
end
