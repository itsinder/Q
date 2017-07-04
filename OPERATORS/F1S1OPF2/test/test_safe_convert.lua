local Q = require 'Q'

local input_col = Q.mk_col({22100000, 125, 200}, "I4")
local expected_col = Q.mk_col({22100, 125, 200}, "I2")
local converted_col = Q.convert(input_col, {qtype = "I2", is_safe=true})
converted_col:eval()

-- Compare converted column with expected column
local n = Q.sum(Q.vveq(expected_col, converted_col))
assert(type(n) == "Scalar")
len = input_col:length()
assert(n:eval() == len, "Converted column not matching with expected result")

-- Check the compare result
Q.print_csv(converted_col, nil, "")
--===========================
print("Successfully completed " .. arg[0])
os.exit()
