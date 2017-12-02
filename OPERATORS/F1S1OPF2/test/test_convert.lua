--  FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local Scalar = require 'libsclr'
local tests = {} 
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local input_col
local expected_col
local converted_col

tests.t7_I1 = function()
  local len = 1048576+17
  local qtypes = {"I1", "I2", "I4", "I8", "F4", "F8" }
  local vals = { 127, -128}
  for _, val in ipairs(vals) do 
    for _, qtype in ipairs(qtypes) do  
      local incol = Q.const({ len = len, qtype = qtype, val = Scalar.new(val, qtype)})
       incol:eval()
       print("XX", Q.sum(incol):eval():to_num())
       local outcol = Q.convert(incol, "I1")
       local alt_incol = Q.convert(outcol, qtype)
       alt_incol:eval()
       -- print(">>>>>>>>>>>>>>>>>>")
       Q.print_csv({incol, alt_incol}, nil, "_xxx_" .. val)
       -- print("<<<<<<<<<<<<<<<<<<")
       -- KRUSHNAKANT print(Q.sum(Q.vvneq(incol, alt_incol)):eval():to_num())
       assert(Q.sum(Q.vvneq(incol, alt_incol)):eval():to_num() == 0)
       os.exit()
    end
  end
  print("Successfully completed test t7_I1")
end

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
  -- test for no-op when no conversion needed
  local incol = Q.mk_col({1, 0, 1}, "I1")
  local outcol = Q.convert(incol, "I1")
  assert(incol == outcol)
  print("Successfully completed test t5")
end
--===========================
tests.t6 = function()
  -- test for no-op when no conversion needed
  local len = 16
  local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
  for _, qtype in ipairs(qtypes) do 
    local incol = Q.period({start = 0, by = 1, period = 2, qtype = qtype, len = len })
    local outcol = Q.convert(incol, "B1")
    local outcol2 = Q.convert(outcol, qtype)
    incol:eval()
    outcol:eval()
    outcol2:eval()
    Q.print_csv({incol, outcol, outcol2}, nil, "")
    os.exit()
    assert(Q.sum(Q.vvneq(incol, outcol2)):eval():to_num() == 0)
  end
  print("Successfully completed test t6")
end
--===========================
return tests
