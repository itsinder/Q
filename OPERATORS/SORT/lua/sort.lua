local function sort(x, ordr)
  local Q       = require 'Q/q_export'
  local qc = require 'Q/UTILS/lua/q_core'

  assert(type(x) == "Column", "error")
  assert(type(ordr) == "string")
  if ( ordr == "ascending" ) then ordr = "asc" end 
  if ( ordr == "descending" ) then ordr = "dsc" end 
  local spfn = require("Q/OPERATORS/SORT/lua/sort_specialize" )
  local status, subs, tmpl = pcall(spfn, x:fldtype(), ordr)
  assert(status, "error in call to sort_specialize")
  assert(type(subs) == "table", "error in call to sort_specialize")
  local func_name = assert(subs.fn)

  local x_len, x_chunk, nn_x_chunk = x:chunk(-1)
  assert(nn_x_chunk == nil, "Cannot sort with null values")
  assert(qc[func_name], "Unknown function " .. func_name)
  qc[func_name](x_chunk, x_len)
  x.set_meta("sort_order", ordr)

end
return require('Q/q_export').export('sort', sort)
