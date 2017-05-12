local mk_col = require 'mk_col'

return function (tests, val_tab, qtype_tab, expected, check, fail)
  local expectedOut;
  assert(type(tests) == "table","tests must be table")
  assert(type(val_tab) == "table","type must be table")
  assert(type(qtype_tab) == "table","type must be table")
  assert(#val_tab == #qtype_tab,"both tables must have same length")
  assert( (check and fail) == nil , "both check and fail cannot be present")
  assert( ((not check) and (not fail)) == false, "both check and fail cannot be nil")
  if check then assert(type(check) == "function","check must be function") end
  if fail then assert(type(fail) == "string","fail must be string") end
  
  for k, v in pairs(qtype_tab) do
    assert(g_valid_types[v],"invalid qtype given")
    if (v == 'I8') then 
      expectedOut = string.gsub(expected, ",", "LL,") 
    else         
      expectedOut = expected 
    end  
  end
  
  local input_args = {}
  for k, v in pairs(val_tab) do
    assert(type(v) == "table", "input must be a table")
    local col = mk_col(v, qtype_tab[k])
    table.insert(input_args, col)
  end
  
  table.insert(tests, {
    input = input_args,
    check = check(expectedOut),
    fail = fail
  })
end  
  