local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

-- TEST SORT TWICE TEST
meta = {
 { name = "empid", has_nulls = true, qtype = "I4", is_load = true }
}
local result = Q.load_csv("I4.csv", meta)
assert(type(result) == "table")
for i, v in pairs(result) do
    x = result[i]
  assert(type(x) == "lVector")
end
 -- Q.print_csv(x, nil, "")

-- Desc & Asc = Asc
Q.sort(x, "dsc")
Q.sort(x, "asc")
Q.print_csv(x, nil, "")

y = Q.mk_col({10,20,30,40,50}, 'I4')
assert(type(y) == "lVector")

cmp_result2 = Q.vveq(x, y)
cmp_result2:eval()
assert(type(cmp_result2) == "lVector")
local sort2 = Q.sum(cmp_result2)
assert(sort2:eval() == y:length())


-- Asc & Dsc = Dsc
local result = Q.load_csv("I4.csv", meta)
assert(type(result) == "table")
for i, v in pairs(result) do
    x = result[i]
  assert(type(x) == "lVector")
end
Q.sort(x, "asc")
Q.sort(x, "dsc")
Q.print_csv(x, nil, "")

z = Q.mk_col({50,40,30,20,10}, 'I4')
assert(type(z) == "lVector")

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