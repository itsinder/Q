local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')

return function(qtype, comparison, optargs)
  local tmpl
  local fast = false
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.mode == "fast" ) then
      tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/par_is_next.tmpl"
      fast = true
    end
  end
  if ( not tmpl ) then tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/is_next.tmpl" end
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
  subs.fast = fast
  subs.comparison = comparison
  subs.ctype = qconsts.qtypes[qtype].ctype
  if ( fast ) then 
    subs.fn = "par_is_next_" .. comparison .. "_" .. qtype
  else
    subs.fn = "is_next_" .. comparison .. "_" .. qtype
  end
  --==============================
  return subs, tmpl
end
