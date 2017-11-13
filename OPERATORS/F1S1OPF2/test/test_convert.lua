--  FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local tests = {} 
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local input_col
local expected_col
local converted_col

tests.t1 = function()
  input_col = Q.mk_col({22100.45, 125.44, 200.8}, "F4")
  expected_col = Q.mk_col({84, 125, -56}, "I1")
  converted_col = Q.convert(input_col, "I1")
  -- Compare converted column with expected column
  local n = Q.sum(Q.vveq(expected_col, converted_col))
  assert(type(n) == "Reducer")
  local len = input_col:length()
  assert(n:eval():to_num() == len)
  -- Q.print_csv(converted_col, nil, "")
  print("Successfully completed test t1")
end
--===========================
tests.t2 = function()
  input_col = Q.mk_col({22, 125, 20}, "I2")
  expected_col = Q.mk_col({22, 125, 20}, "I1")
  converted_col = Q.convert(input_col, "I1")
  -- Compare converted column with expected column
  local n = Q.sum(Q.vveq(expected_col, converted_col))
  assert(type(n) == "Reducer")
  local len = input_col:length()
  assert(n:eval():to_num() == len)
  -- Q.print_csv(converted_col, nil, "")
  print("Successfully completed test t2")
end
--===========================

tests.t3 = function() 
  input_col = Q.mk_col({1, 0, 1}, "B1")
  local expected_res = {1, 0, 1}
  converted_col = Q.convert(input_col, "I1")
  -- Compare converted column with expected column
  for i, v in pairs(expected_res) do
    local val = c_to_txt(converted_col, i)
    assert(val == v, "Value mismatch")
  end
 --  Q.print_csv(converted_col, nil, "")
  print("Successfully completed test t3")
end

--===========================
tests.t4 = function()
  input_col = Q.mk_col({1, 0, 1}, "I1")
  local expected_res = {1, 0, 1}
  converted_col = Q.convert(input_col, "B1")
  -- Compare converted column with expected column
  for i, v in pairs(expected_res) do
    local val = c_to_txt(converted_col, i)
    if not val then val = 0 end
    assert(val == v, "Value mismatch")
  end
  -- Q.print_csv(converted_col, nil, "")
  print("Successfully completed test t4")
end
--===========================
tests.t5 = function()
  -- test for no-op when no conversionneeded
  local incol = Q.mk_col({1, 0, 1}, "I1")
  local outcol = Q.convert(incol, "I1")
  assert(incol == outcol)
  print("Successfully completed test t5")
end
--===========================
return tests
