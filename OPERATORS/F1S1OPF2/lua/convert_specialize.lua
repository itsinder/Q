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
  assert(is_base_qtype(out_qtype) or ( out_qtype == "B1" ) )
  assert(is_base_qtype(in_qtype) or ( in_qtype == "B1" ) )
  local out_ctype = assert(qconsts.qtypes[out_qtype].ctype, out_qtype)
  local in_ctype  = assert(qconsts.qtypes[in_qtype].ctype, in_qtype)
  
  local tmpl = 'f1opf2.tmpl'
  local subs = {};
  subs.fn = "convert_" .. in_qtype .. "_" .. out_qtype
  subs.c_code_for_operator = "c = (" .. out_ctype .. ") a; "
  subs.out_qtype = out_qtype
  subs.in_ctype = in_ctype
  subs.out_ctype = out_ctype
  subs.c_mem = nil  
  
  if is_safe then
    tmpl = 'safe_f1opf2.tmpl'
    subs.fn = "safe_convert_" .. in_qtype .. "_" .. out_qtype
    subs.min_val = assert(qconsts.qtypes[out_qtype].min)
    subs.max_val = assert(qconsts.qtypes[out_qtype].max)
    subs.is_safe = is_safe
  elseif out_qtype == "B1" or in_qtype == "B1" then
    tmpl = 'convert_B1.tmpl'
    if out_qtype == "B1" then
      subs.in_fn = "inv = in[i];"
      subs.out_fn = "if ( inv == 1 ) { mcr_set_bit(out[widx], bidx); }"
      --subs.out_ctype = "uint64_t"
    else
      subs.in_fn = "inv = mcr_get_bit(in[widx], bidx); if ( inv != 0 ) { inv = 1; }"
      subs.out_fn = "out[i] = inv;"
      --subs.in_ctype = "uint64_t"
    end    
  end
  return subs, tmpl
end
