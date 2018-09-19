
return function (
  in_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local Scalar  = require 'libsclr'

  local out_qtype 
  if ( in_qtype == "I8" ) then 
    out_qtype = "I4"
  elseif ( in_qtype == "I4" ) then 
    out_qtype = "I2"
  elseif ( in_qtype == "I2" ) then 
    out_qtype = "I1"
  else
    assert(nil, "Bad in_qtype = " .. in_qtype)
  end

  local tmpl = 'split.tmpl'
  local subs = {}; 
  subs.fn = "split_" .. in_qtype .. "_" .. out_qtype 
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.out_qtype = out_qtype
  subs.out_ctype = qconsts.qtypes[out_qtype].ctype
  return subs, tmpl
end
