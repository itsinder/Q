
return function (
  qtype, 
  is_safe
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local pltable = require 'pl.tablex'
  local qtypes = { 'I1', 'I2', 'I4', 'I8' }
  print(qtype)
  assert(pltable.find(qtypes, qtype))
  local tmpl = 'numby.tmpl'
  local subs = {};
  subs.ctype = assert(qconsts.qtypes[qtype].ctype)
  subs.qtype = qtype
  subs.fn = "numby_" .. qtype 
  subs.checking_code = " /* No checks made on value */ "
  subs.bye = " "
  if ( is_safe ) then 
    subs.fn = subs.fn .. "_safe"
    subs.checking_code = " if ( ( x < 0 ) || ( x >= (" 
      .. subs.ctype ..  ")nZ ) ) { go_BYE(-1); }  "
    subs.bye = "BYE: "
  end
  return subs, tmpl
end
