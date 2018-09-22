local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local plfile = require 'pl.file'
local Scalar  = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
return function (
  qtype,
  comparison,
  optargs
  )
  local default_val 
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.default_val ) then 
      assert(type(optargs.default_val) == "number")
      default_val = optargs.default_val
      assert( ( default_val == 1 ) or ( default_val == 0 ) ) 
    end
  end
  local subs = {}
  --== check the comparison 
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
  --===========================================
  subs.qtype = qtype
  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.fn = "is_prev_" .. comparison .. "_" .. qtype
  subs.tmpl = 'is_prev.tmpl'
  subs.default_val = default_val
  --==============================
  return subs, tmpl
end
