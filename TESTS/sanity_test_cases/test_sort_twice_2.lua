local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- TEST SORT TWICE TEST
x = Q.mk_col({10,50,40,30}, 'I4')

z = Q.mk_col({50,40,30,10}, 'I4')

assert(type(x) == "lVector")

assert(type(z) == "lVector")

-- Asc & Dsc = Dsc
Q.sort(x, "asc")
Q.sort(x, "dsc")
Q.print_csv(x, nil, "")

cmp_result22 = Q.vveq(x, z)
cmp_result22:eval()
assert(type(cmp_result22) == "lVector")
local sort22 = Q.sum(cmp_result22)
assert(sort22:eval() == z:length())

print("##########")
print("Nested SORT Test DONE !!")
print("------------------------------------------")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
