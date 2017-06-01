function sort(x, ordr)

  local q = require 'Q/UTILS/lua/q'
  assert(type(x) == "Column", "error")
  local spfn = require("Q/OPERATORS/SORT/lua/sort_specialize" )
  local status, subs, tmpl = pcall(spfn, x:fldtype(), ordr)
  assert(status, "error")
  assert(type(subs) == "table", "error")
  local func_name = assert(subs.fn)

  local x_len, x_chunk, nn_x_chunk = x:chunk(-1)
  assert(nn_x_chunk == nil, "Cannot sort with null values")
  q[func_name](x_chunk, x_len)

end
