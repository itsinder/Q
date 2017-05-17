local g_err = require 'error_code'
-- This function will work on those operator functions
-- which takes 2 arrays as input
-- and return output
-- example - add, sub, multiply, division etc
return function (tests, operation, val_tab, qtype_tab, qtype_output, expected, check, fail)
  local expectedOut;
  assert(type(tests) == "table", g_err.INPUT_NOT_TABLE)
  assert(type(val_tab) == "table", g_err.INPUT_NOT_TABLE)
  assert(type(qtype_tab) == "table", g_err.INPUT_NOT_TABLE)
  assert(#val_tab == #qtype_tab, g_err.LENGTH_NOT_EQUAL_ERROR)
  --assert(g_valid_types[qtype_output],g_err.INVALID_QTYPE)
  -- either check or fail must be present.
  -- both cannot be present
  -- both of them cannot be nil
  assert( (check and fail) == nil, g_err.CHECK_FAIL_PRESENT)
  assert( ((not check) and (not fail)) == false, g_err.CHECK_FAIL_NIL)
  if check then assert(type(check) == "function", g_err.CHECK_NOT_FUNCTION) end
  if fail then assert(type(fail) == "string", g_err.FAIL_NOT_STRING) end
  
  -- input args are in the order below
  -- operation
  -- qtype_output
  -- qtype_input1
  -- qtype_input2
  -- input1
  -- input2
  local input_args = {}
  table.insert(input_args, operation)
  
  for k, v in pairs(qtype_tab) do
    assert(g_valid_types[v], g_err.INVALID_QTYPE)
    table.insert(input_args, v)
    if (v == 'I8') then 
      -- remove trailing LL. in case of I8, number to string conversion adds
      -- LL at the endo of the string
      expectedOut = string.gsub(expected, ",", "LL,") 
    else         
      expectedOut = expected 
    end  
  end
  
  for k, v in pairs(val_tab) do
    assert(type(v) == "table", g_err.INPUT_NOT_TABLE)
    table.insert(input_args, v)
  end

  table.insert(input_args, qtype_output)
  
  table.insert(tests, {
    input = input_args,
    check = check(expectedOut),
    fail = fail
  })
end  
  