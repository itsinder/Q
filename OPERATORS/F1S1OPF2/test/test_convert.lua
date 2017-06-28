local Q = require 'Q'

local input_col = Q.mk_col({22100.45, 125.44, 200.8}, "F4")
local expected_col = Q.mk_col({84, 125, -56}, "I1")
local converted_col = Q.convert(input_col, {qtype = "I1"})
converted_col:eval()

-- Compare converted column with expected column
local cmp_col = Q.vveq(expected_col, converted_col)
cmp_col:eval()

-- Check the compare result
Q.print_csv(cmp_col, nil, "")
--===========================
print("Successfully completed" .. arg[0])
os.exit()
