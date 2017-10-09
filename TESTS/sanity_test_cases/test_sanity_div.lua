-- This test checks that division of a vector by null vector dies with "floating point expection" error.
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- SANITY TEST
a = Q.mk_col({1, 2, 3}, "I4")
b = Q.mk_col({0, 0, 0}, "I4")

div_result = Q.vvdiv(a, b, { junk = "junk" })
div_result:eval()
assert(type(div_result) == "Column")
--Q.print_csv(div_result, nil, "")
--print("##########")

print("Sanity div Test DONE !!")
print("------------------------------------------")

print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
