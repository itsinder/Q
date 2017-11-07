local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
require 'Q/UTILS/lua/strict'

local input_col = Q.mk_col({22100, 125, 20}, "I4")

-- Expected column
local expected_col = Q.mk_col({0, 125, 20}, "I1")

-- Expected nn_vec elements
local expected_nn_val = {0, 1, 1}

-- Convert column
local converted_col = Q.convert(input_col, "I1", {is_safe=true})
converted_col:eval()

-- Check nn_vec
for k, v in ipairs(expected_nn_val) do
  value, nn_value = c_to_txt(converted_col, k)
  --nn_value = converted_col.nn_vec:get_element(k - 1)
  if nn_value == nil then nn_value = 0 end
  assert(v == nn_value, "nn vector not matching")
end
print("nn_vec check successful")

-- Compare converted column with expected column
local n = Q.sum(Q.vveq(expected_col, converted_col))
assert(type(n) == "Reducer")
len = input_col:length()
assert(n:eval() == len, "Converted column not matching with expected result")

-- Check the compare result
Q.print_csv(converted_col, nil, "")
--===========================
print("-------------------------------------------")
local input_col = Q.mk_col({2211, 125, 20}, "I4")

-- Expected column
local expected_col = Q.mk_col({2211, 125, 20}, "I2")

-- Expected nn_vec elements
local expected_nn_val = {1, 1, 1}

-- Convert column
local converted_col = Q.convert(input_col, "I2", {is_safe=true})
converted_col:eval()

-- Check nn_vec
for k, v in ipairs(expected_nn_val) do
  value, nn_value = c_to_txt(converted_col, k)
  --nn_value = converted_col.nn_vec:get_element(k - 1)
  if nn_value == nil then nn_value = 0 end
  assert(v == nn_value, "nn vector not matching")
end
print("nn_vec check successful")

-- Compare converted column with expected column
local n = Q.sum(Q.vveq(expected_col, converted_col))
assert(type(n) == "Reducer")
len = input_col:length()
assert(n:eval() == len, "Converted column not matching with expected result")

-- Check the compare result
Q.print_csv(converted_col, nil, "")
--===========================

print("Successfully completed " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
