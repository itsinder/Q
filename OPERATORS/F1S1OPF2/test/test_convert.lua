local Q = require 'Q'

local input_col = Q.mk_col({22100.45, 125.44, 200.8}, "F4")
local expected_col = Q.mk_col({84, 125, -56}, "I1")
local converted_col = Q.convert(input_col, {qtype = "I1"})
converted_col:eval()

-- Compare converted column with expected column
local n = Q.sum(Q.vveq(expected_col, converted_col))
assert(type(n) == "Scalar")
len = input_col:length()
assert(n:eval() == len)

-- Check the compare result
Q.print_csv(converted_col, nil, "")
--===========================
print("Successfully completed " .. arg[0])
os.exit()
