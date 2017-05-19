function sort(x, ordr)

  assert(type(x) == "Column", "error")
  assert(type(ordr) == "string", "error")
  assert( ( ( ordr == "asc") or ( ordr == "dsc" ) ), "error")
  local spfn = require("sort_specialize" )
  status, subs, tmpl = pcall(spfn, x:fldtype(), ordr)
  assert(status, "error")
  assert(type(subs) == "table", "error")
  local func_name = assert(subs.fn)

  x_len, x_chunk, nn_x_chunk = x:chunk(-1)
  q[func_name](x_chunk, x_len)

end
