local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- TEST SORT TWICE TEST
x = Q.mk_col({10,50,40,30}, 'I4')
y = Q.mk_col({10,30,40,50}, 'I4')
z = Q.mk_col({50,40,30,10}, 'I4')

assert(type(x) == "lVector")
assert(type(y) == "lVector")
assert(type(z) == "lVector")

-- Desc & Asc = Asc
Q.sort(x, "dsc")
Q.sort(x, "asc")
Q.print_csv(x, nil, "")

cmp_result2 = Q.vveq(x, y)
cmp_result2:eval()
assert(type(cmp_result2) == "lVector")
local sort2 = Q.sum(cmp_result2)
assert(sort2:eval() == y:length())

-- Asc & Dsc = Dsc
x = Q.mk_col({10,50,40,30}, 'I4')
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
