-- Test arithmetic behaviour of the operators of Q
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'


-- F1F2OPF3 TEST
a = Q.mk_col({1, 2, 3}, "I4")
b = Q.mk_col({1, 2, 3}, "I4")


-- (a+b)/a
c = Q.mk_col({2, 2, 2}, "I4")


dmas1_result = Q.vvdiv(Q.vvadd(a, b, { junk = "junk" }), a, { junk = "junk" })
dmas1_result:eval()
assert(type(dmas1_result) == "lVector")
---Q.print_csv(dmas1_result, nil, "")
--print("##########")
cmp_result = Q.vveq(dmas1_result, c)
cmp_result:eval()
assert(type(cmp_result) == "lVector")
--Q.print_csv(cmp_result, nil, "")
local dmas1 = Q.sum(cmp_result)
assert(dmas1:eval() == a:length())
assert(dmas1:eval() == b:length())
assert(dmas1:eval() == c:length())

Q.print_csv(dmas1_result, nil, "")
print("F1F2OPF3 dmas Test 1 DONE !!")
print("------------------------------------------")


-- a + b/a
d = Q.mk_col({2, 3, 4}, "I4")

dmas2_result = Q.vvadd(a, Q.vvdiv(b, a, { junk = "junk" }), { junk = "junk" })
dmas2_result:eval()
assert(type(dmas2_result) == "lVector")
--Q.print_csv(dmas2_result, nil, "")
--print("##########")
cmp_result = Q.vveq(dmas2_result, d)
cmp_result:eval()
assert(type(cmp_result) == "lVector")
--Q.print_csv(cmp_result, nil, "")
local dmas2 = Q.sum(cmp_result)
assert(dmas2:eval() == a:length())
assert(dmas2:eval() == b:length())
assert(dmas2:eval() == d:length())

Q.print_csv(dmas2_result, nil, "")
print("F1F2OPF3 dmas Test 2 DONE !!")
print("------------------------------------------")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
