--  FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local input_col
local expected_col
local converted_col

input_col = Q.mk_col({22100.45, 125.44, 200.8}, "F4")
expected_col = Q.mk_col({84, 125, -56}, "I1")
converted_col = Q.convert(input_col, {qtype = "I1"})
converted_col:eval()

-- Compare converted column with expected column
local n = Q.sum(Q.vveq(expected_col, converted_col))
assert(type(n) == "Reducer")
len = input_col:length()
assert(n:eval() == len)

-- Check the compare result
Q.print_csv(converted_col, nil, "")
--===========================

print("------------------------------------------")

input_col = Q.mk_col({22, 125, 20}, "I2")
expected_col = Q.mk_col({22, 125, 20}, "I1")
converted_col = Q.convert(input_col, {qtype = "I1"})
converted_col:eval()

-- Compare converted column with expected column
local n = Q.sum(Q.vveq(expected_col, converted_col))
assert(type(n) == "Reducer")
len = input_col:length()
assert(n:eval() == len)

-- Check the compare result
Q.print_csv(converted_col, nil, "")
--===========================

print("------------------------------------------")

input_col = Q.mk_col({1, 0, 1}, "B1")
expected_res = {1, 0, 1}
converted_col = Q.convert(input_col, {qtype = "I1"})
converted_col:eval()

-- Compare converted column with expected column
for i, v in pairs(expected_res) do
  val = c_to_txt(converted_col, i)
  assert(val == v, "Value mismatch")
end

-- Print Column
Q.print_csv(converted_col, nil, "")
--===========================

print("------------------------------------------")

input_col = Q.mk_col({1, 0, 1}, "I1")
expected_res = {1, 0, 1}
converted_col = Q.convert(input_col, {qtype = "B1"})
converted_col:eval()

-- Compare converted column with expected column
for i, v in pairs(expected_res) do
  val = c_to_txt(converted_col, i)
  if not val then val = 0 end
  assert(val == v, "Value mismatch")
end

-- Print Column
Q.print_csv(converted_col, nil, "")
--===========================


print("Successfully completed " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
