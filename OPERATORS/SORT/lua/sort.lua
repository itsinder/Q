local function sort(x, ordr)
  local Q       = require 'Q/q_export'
  local qc = require 'Q/UTILS/lua/q_core'

  assert(type(x) == "Column", "error")
  local spfn = require("Q/OPERATORS/SORT/lua/sort_specialize" )
  local status, subs, tmpl = pcall(spfn, x:fldtype(), ordr)
  assert(status, "error in call to " .. spfn)
  assert(type(subs) == "table", "error in call to " .. spfn)
  local func_name = assert(subs.fn)

  local x_len, x_chunk, nn_x_chunk = x:chunk(-1)
  assert(nn_x_chunk == nil, "Cannot sort with null values")
  assert(qc[func_name], "Unknown function " .. func_name)
  qc[func_name](x_chunk, x_len)

end
return require('Q/q_export').export('sort', sort)
