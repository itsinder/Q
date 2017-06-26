return function (
  in_qtype,
  scalar
  )

  local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
  local qconsts = require 'Q/UTILS/lua/q_consts'

  assert(is_base_qtype(in_qtype))
  local scalar_val = nil
  local scalar_qtype = nil

  if ( type(scalar) == "table" ) then
    scalar_val = scalar.value
    if ( scalar.qtype ) then
      scalar_qtype = scalar.qtype
    else
      scalar_qtype = in_qtype
    end
  else
    scalar_val = scalar
    assert( ( type(scalar_val) == "string") or ( type(scalar_val) == "number") )
    scalar_qtype = in_qtype
  end
  local out_qtype = scalar_qtype

  local tmpl = 'f1opf2.tmpl'
  local subs = {};
  subs.fn = "convert_" .. in_qtype .. "_" .. scalar_qtype
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.out_qtype = out_qtype
  subs.out_ctype = qconsts.qtypes[subs.out_qtype].ctype
  subs.c_code_for_operator = "c = (" .. subs.out_ctype .. ") a"
  subs.c_mem = nil
  return subs, tmpl

end
