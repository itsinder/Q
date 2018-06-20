-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'

-- validating unique operator to return unique values from input vector
-- where num_elements are less than chunk_size
local tests = {}
tests.t1 = function ()
  local out_table = {1, 2, 3, 4, 5}
  local a = Q.mk_col({1, 2, 2, 3, 3, 3, 3, 4, 5}, "I4")
  local c = Q.unique(a):eval()
  assert(c:length() == #out_table)

  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])
  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t1 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size 
tests.t2 = function ()
  local out_table = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  local input = Q.period({ len = 65536*4+2, start = 1, by = 1, period = 10, qtype = "I4"}):persist(true):eval()
  
  local input_col = Q.sort(input, "asc")
  -- Q.print_csv(input_col, {opfile = "input_file.csv"})
  local c = Q.unique(input_col):eval()
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, out_table[i])
    assert(value == out_table[i])
  end
  print("Test t2 succeeded")
end
 
return tests
