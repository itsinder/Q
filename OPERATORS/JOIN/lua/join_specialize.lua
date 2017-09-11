local qconsts = require 'Q/UTILS/lua/q_consts'

return function( src_val_type, src_lnk_type, dst_lnk_type, dst_val_type)
  local plfile = require 'pl.file'
  local subs = {}
  local tmpl = plfile.read('join.tmpl')
  subs.src_val_ctype = qconsts.qtypes[src_val_type].ctype;
  subs.src_lnk_ctype = qconsts.qtypes[src_lnk_type].ctype;
  subs.dst_lnk_ctype = qconsts.qtypes[dst_lnk_type].ctype;
  return subs, tmpl
end
