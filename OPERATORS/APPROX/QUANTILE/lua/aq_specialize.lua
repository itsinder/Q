return function (
  qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))

  --==============================
  local subs = {}
  local tmpls = {'approx_quantile.tmpl', 'New.tmpl', 'Output.tmpl', 'Collapse.tmpl'}

  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.qtype = qtype
  --subs.fn = "approx_quantile_" .. qtype
  return subs, tmpls
end
