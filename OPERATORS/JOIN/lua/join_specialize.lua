return function( src_val_type, src_lnk_type, dst_lnk_type, dst_val_type)
  local subs = {}
  local tmpl = 'join.tmpl'
  subs.src_val_type = g_qtypes[src_val_type].ctype;
  return subs, tmpl
end
