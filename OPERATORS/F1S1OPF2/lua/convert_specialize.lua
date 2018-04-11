local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local qconsts       = require 'Q/UTILS/lua/q_consts'

return function (
  in_qtype,
  out_qtype,
  args
  )
  local is_safe   = nil
  if ( args ) then 
    assert(type(args) == "table" )
    if ( args.is_safe ) then 
      is_safe = args.is_safe
      assert(type(is_safe) == "boolean")
    end
  end
  assert(in_qtype ~= out_qtype)
  assert(is_base_qtype(out_qtype) or ( out_qtype == "B1" ) )
  assert(is_base_qtype(in_qtype) or ( in_qtype == "B1" ) )
  local out_ctype = assert(qconsts.qtypes[out_qtype].ctype, out_qtype)
  local in_ctype  = assert(qconsts.qtypes[in_qtype].ctype, in_qtype)
  
  local tmpl = 'f1opf2.tmpl'
  local subs = {};
  subs.fn = "convert_" .. in_qtype .. "_" .. out_qtype
  subs.c_code_for_operator = "c = (" .. out_ctype .. ") a; "
  subs.in_qtype = in_qtype
  subs.out_qtype = out_qtype
  subs.in_ctype = in_ctype
  subs.out_ctype = out_ctype
  -- TODO We should not need to do this. Will delete when fixed in q_consts
  if ( in_qtype  == "B1" ) then subs.in_ctype = "uint64_t" end
  if ( out_qtype == "B1" ) then subs.out_ctype = "uint64_t" end
  subs.c_mem = nil  
  
  if is_safe then
    tmpl = 'safe_f1opf2.tmpl'
    subs.fn = "safe_convert_" .. in_qtype .. "_" .. out_qtype
    subs.in_qtype = in_qtype
    subs.out_qtype = out_qtype
    subs.min_val = assert(qconsts.qtypes[out_qtype].min)
    subs.max_val = assert(qconsts.qtypes[out_qtype].max)
    subs.is_safe = is_safe
  else
    if out_qtype == "B1" then
      tmpl = 'convert_to_B1.tmpl'
      subs.out_ctype = "uint64_t"
    elseif in_qtype == "B1" then 
      tmpl = 'convert_from_B1.tmpl'
      subs.in_ctype = "uint64_t"
    else
      tmpl = 'convert.tmpl'
    end    
  end
  return subs, tmpl
end
