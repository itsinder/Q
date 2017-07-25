local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local qconsts = require 'Q/UTILS/lua/q_consts'

return function (
  in_qtype,
  args
  )
  local out_qtype = nil
  local is_safe   = nil
  if ( type(args) == "table" ) then
    out_qtype = assert(args.qtype)
    is_safe = args.is_safe
    if ( not is_safe ) then is_safe = false end 
  elseif ( type(args) == "string" ) then
    out_qtype = args
    is_safe = false
  else
    assert(nil, "ERROR")
  end
  assert(is_base_qtype(out_qtype), "Cannot convert to type " .. out_qtype)
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  local in_ctype = qconsts.qtypes[in_qtype].ctype
  
  local tmpl = 'f1opf2.tmpl'
  local subs = {};
  subs.fn = "convert_" .. in_qtype .. "_" .. out_qtype
  if is_safe then
    tmpl = 'safe_f1opf2.tmpl'
    subs.min_val = qconsts.qtypes[out_qtype].min
    subs.max_val = qconsts.qtypes[out_qtype].max
    subs.fn = "safe_convert_" .. in_qtype .. "_" .. out_qtype
    subs.is_safe = is_safe
  end
  subs.c_code_for_operator = "c = (" .. out_ctype .. ") a; "
  subs.out_qtype = out_qtype
  subs.in_ctype = in_ctype
  subs.out_ctype = out_ctype
  subs.c_mem = nil
  return subs, tmpl
end
