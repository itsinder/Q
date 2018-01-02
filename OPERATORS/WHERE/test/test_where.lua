-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local a = Q.mk_col({10, 20, 30, 40, 50}, "I4"):set_name("a")

local tests = {}
tests.t1 = function ()
  local b = Q.mk_col({1, 0, 0, 1, 0}, "B1")
  local out_table = {10, 40}
  local c = Q.where(a, b):eval()
  assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")

  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])
  end
  -- Q.print_csv(c, nil, "")
  print("Test t1 succeeded")
end
--======================================
tests.t2 = function ()
  b = Q.mk_col({0, 0, 0, 0, 0}, "B1"):set_name("b")
  print(a:length())
  print(b:length())
  assert(Q.where(a, b):set_name("c"):eval() == nil)
  print("Test t2 succeeded")
end
--======================================
tests.t3 = function ()
  b = Q.mk_col({1, 1, 1, 1, 1}, "B1")
  local out_table = {10, 20, 30, 40, 50}
  local c = Q.where(a, b):eval()
  assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])
  end
  -- Q.print_csv(c, nil, "")
end
--======================================
tests.t4 = function ()
  b = Q.mk_col({0, 0, 0, 0, 0}, "B1")
  b:set_meta("min", 0)
  b:set_meta("max", 0)
  local c = Q.where(a, b)
  assert(c == nil)
end
--======================================
tests.t5 = function ()
  b = Q.mk_col({1, 1, 1, 1, 1}, "B1")
  b:set_meta("min", 1)
  b:set_meta("max", 1)
  local c = Q.where(a, b)
  assert(c == a)
end
--======================================
tests.t6 = function ()
  print("=======================================")
  -- more than chunk size values present in a and b

  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 65538} )
  --a:eval()
  local len = 65538
  --local a_input_table = {}
  local b_input_table = {}
  for i=1, len do
    b_input_table[i] = 0
    --a_input_table[i] = i
  end
  b_input_table[2] = 1
  b_input_table[4] = 1
  b_input_table[len] = 1
  local b = Q.mk_col(b_input_table, "B1")
  --local a = Q.mk_col(a_input_table, "I4")
  local expected_out = {2, 4, len}
  
  --Q.print_csv(a, nil, "/tmp/a_out.txt")
  --Q.print_csv(b, nil, "/tmp/b_out.txt")
  
  local c = Q.where(a, b)
  c:eval()
 
  --Q.print_csv(c, nil, "") 
  assert(c:length() == #expected_out, "Length Mismatch, Expected: " .. #expected_out .. " Actual: " .. c:length())
  --assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")

  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == expected_out[i], "Value Mismatch, Expected: " .. expected_out[i] .. " Actual: " .. value)
  end
end
--======================================

tests.t7 = function ()
  print("=======================================")
  -- more than chunk size values present in a and b

  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 65538} )
  a:eval()
  
  -- First chunk contains all 1
  local b_input_table = {}
  for i=1, 65538 do
    b_input_table[i] = 1
  end
  b_input_table[65537] = 0
  local b = Q.mk_col(b_input_table, "B1")

  local expected_out = {}
  for i = 1, 65536 do
    expected_out[i] = i
  end
  expected_out[65537] = 65538
  
  --Q.print_csv(a, nil, "/tmp/a_out.txt")
  --Q.print_csv(b, nil, "/tmp/b_out.txt")
  
  local c = Q.where(a, b)
  c:eval()
  
  assert(c:length() == #expected_out, "Length Mismatch, Expected: " .. #expected_out .. " Actual: " .. c:length())
  --assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")

  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == expected_out[i], "Value Mismatch, Expected: " .. expected_out[i] .. " Actual: " .. value)
  end
end
--=========================================
return tests
