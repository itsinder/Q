local function idx_sort(idx, x, ordr)
  local Q       = require 'Q/q_export'
  local qc = require 'Q/UTILS/lua/q_core'

  assert(type(idx) == "lVector", "error")
  assert(type(x) == "lVector", "error")
  assert(type(ordr) == "string")
  if ( ordr == "ascending"  ) then ordr = "asc" end 
  if ( ordr == "descending" ) then ordr = "dsc" end 
  local spfn = require("Q/OPERATORS/SORT/lua/idx_sort_specialize" )
  local status, subs, tmpl = pcall(spfn, idx:fldtype(), x:fldtype(), ordr)
  assert(status, "error in call to sort_specialize")
  assert(type(subs) == "table", "error in call to sort_specialize")
  local func_name = assert(subs.fn)

  -- TODO Check is already sorted correct way and don't repeat
  local x_len, x_chunk, nn_x_chunk = x:start_write()
  assert(x_len > 0, "Cannot sort null vector")
  assert(not nn_x_chunk, "Cannot sort with null values")
  assert(qc[func_name], "Unknown function " .. func_name)
  qc[func_name](x_chunk, x_len)
  x:end_write()
  x:set_meta("sort_order", ordr)

end
return require('Q/q_export').export('sort', sort)
