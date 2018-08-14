local function qsort2(x, y, ordr)
  local Q       = require 'Q/q_export'
  local qc = require 'Q/UTILS/lua/q_core'
  local get_ptr = require 'Q/UTILS/lua/get_ptr'

  assert(type(x) == "lVector", "error")
  assert(type(y) == "lVector", "error")
  -- Check the vector x for eval(), if not then call eval()
  if not x:is_eov() then
    x:eval()
  end
  if not y:is_eov() then
    y:eval()
  end  
  assert(type(ordr) == "string")
  if ( ordr == "ascending" ) then ordr = "asc" end 
  if ( ordr == "descending" ) then assert(nil, "TODO") end 
  local spfn = require("Q/OPERATORS/SORT2/lua/qsort2_specialize" )
  local status, subs, tmpl = pcall(spfn, x:fldtype(), ordr)
  assert(status, "error in call to sort2_asc_specialize")
  assert(type(subs) == "table", "error in call to sort2_asc_specialize")
  local func_name = assert(subs.fn)
  print(func_name)
  -- TODO Check is already sorted correct way and don't repeat
  local x_len, x_chunk, nn_x_chunk = x:start_write()
  local y_len, y_chunk, nn_y_chunk = y:start_write()
  assert(x_len > 0, "Cannot sort null vector")
  assert(y_len > 0, "Cannot sort null vector")
  assert(not nn_x_chunk, "Cannot sort with null values")
  assert(not nn_y_chunk, "Cannot sort with null values")
  assert(qc[func_name], "Unknown function " .. func_name)
  qc[func_name](get_ptr(x_chunk),get_ptr(y_chunk), x_len)
  x:end_write()
  y:end_write()
  x:set_meta("sort_order", ordr)
  --TODO for y sort_order???
  return x

end
return require('Q/q_export').export('qsort2', qsort2)