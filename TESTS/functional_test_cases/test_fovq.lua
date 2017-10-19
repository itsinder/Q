-- Test arithmetic operators of Q
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'


-- F1F2OPF3 TEST
a = Q.mk_col({1, 2, 3}, "I4")
b = Q.mk_col({1, 2, 3}, "I4")


-- ADD
c = Q.mk_col({2, 4, 6}, "I4")

add_result = Q.vvadd(a, b, { junk = "junk" })
add_result:eval()
assert(type(add_result) == "lVector")
--Q.print_csv(add_result, nil, "")
--print("##########")
cmp_result = Q.vveq(add_result, c)
cmp_result:eval()
assert(type(cmp_result) == "lVector")
--Q.print_csv(cmp_result, nil, "")
local sum = Q.sum(cmp_result)
assert(sum:eval() == a:length())
assert(sum:eval() == b:length())
assert(sum:eval() == c:length())

Q.print_csv(add_result, nil, "")
print("F1F2OPF3 add Test DONE !!")
print("------------------------------------------")

-- SUBTRACT
d = Q.mk_col({0, 0, 0}, "I4")
sub_result = Q.vvsub(a, b, { junk = "junk" })
sub_result:eval()
assert(type(sub_result) == "lVector")
---Q.print_csv(sub_result, nil, "")
--print("##########")
cmp_result = Q.vveq(sub_result, d)
cmp_result:eval()
assert(type(cmp_result) == "lVector")
--Q.print_csv(cmp_result, nil, "")
local diff = Q.sum(cmp_result)
assert(diff:eval() == a:length())
assert(diff:eval() == b:length())
assert(diff:eval() == d:length())

Q.print_csv(sub_result, nil, "")
print("F1F2OPF3 sub Test DONE !!")
print("------------------------------------------")


-- MULTIPLY
e = Q.mk_col({1, 4, 9}, "I4")
mul_result = Q.vvmul(a, b, { junk = "junk" })
mul_result:eval()
assert(type(mul_result) == "lVector")
---Q.print_csv(mul_result, nil, "")
--print("##########")
cmp_result = Q.vveq(mul_result, e)
cmp_result:eval()
assert(type(cmp_result) == "lVector")
--Q.print_csv(cmp_result, nil, "")
local mul = Q.sum(cmp_result)
assert(mul:eval() == a:length())
assert(mul:eval() == b:length())
assert(mul:eval() == e:length())

Q.print_csv(mul_result, nil, "")
print("F1F2OPF3 mul Test DONE !!")
print("------------------------------------------")



-- DIVIDE
f = Q.mk_col({1, 1, 1}, "I4")
div_result = Q.vvdiv(a, b, { junk = "junk" })
div_result:eval()
assert(type(div_result) == "lVector")
--Q.print_csv(div_result, nil, "")
--print("##########")
cmp_result = Q.vveq(div_result, f)
cmp_result:eval()
assert(type(cmp_result) == "lVector")
--Q.print_csv(cmp_result, nil, "")
local div = Q.sum(cmp_result)
assert(div:eval() == a:length())
assert(div:eval() == b:length())
assert(div:eval() == f:length())

Q.print_csv(div_result, nil, "")
print("F1F2OPF3 div Test DONE !!")
print("------------------------------------------")

print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()





