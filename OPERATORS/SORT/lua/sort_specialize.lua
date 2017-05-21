return function(in_qtype, ordr)
  assert(type(ordr) == "string", "error")
  if ( ordr == "ascending" ) then ordr = "asc" end 
  if ( ordr == "descending" ) then ordr = "dsc" end 
  assert( ( ( ordr == "asc") or ( ordr == "dsc") ), "error")
  local subs = {}
  local tmpl = 'qsort.tmpl'
  subs.SORT_ORDER = ordr
  subs.QTYPE = in_qtype
  subs.fn = "qsort_" .. ordr .. "_" .. in_qtype
  tmpl.FLDTYPE = g_qtypes[f].ctype
  -- TODO Check below is correct order/comparator combo
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.COMPARATOR = c
  return subs, tmpl
end
