
return function (
  val_qtype, 
  grpby_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local pltable = require 'pl.tablex'
  local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
  local grpby_qtypes = { 'I1', 'I2', 'I4', 'I8' }
  assert(pltable.find(val_qtypes, val_qtype))
  assert(pltable.find(grpby_qtypes, grpby_qtype))
  local tmpl = 'minby.tmpl'
  local subs = {};
  subs.fn = "minby_" .. val_qtype .. "_" .. grpby_qtype .. "_" .. val_qtype
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype
  subs.grpby_ctype = qconsts.qtypes[grpby_qtype].ctype
  subs.out_qtype = val_qtype
  subs.out_ctype = qconsts.qtypes[val_qtype].ctype
  subs.t_reducer = "mcr_min"
  if ( val_qtype == "I1" ) then subs.initial_val = qconsts.qtypes[val_qtype].max end
  if ( val_qtype == "I2" ) then subs.initial_val = qconsts.qtypes[val_qtype].max end
  if ( val_qtype == "I4" ) then subs.initial_val = qconsts.qtypes[val_qtype].max end
  if ( val_qtype == "I8" ) then subs.initial_val = qconsts.qtypes[val_qtype].max end
  if ( val_qtype == "F4" ) then subs.initial_val = qconsts.qtypes[val_qtype].max end
  if ( val_qtype == "F8" ) then subs.initial_val = qconsts.qtypes[val_qtype].max end
  return subs, tmpl
end
