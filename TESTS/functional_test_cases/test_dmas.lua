-- Test arithmetic behaviour of the operators of Q
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

a = Q.mk_col({1, 2, 3}, "I4")
b = Q.mk_col({1, 2, 3}, "I4")

local tests = {}
tests.t1 = function ()

-- F1F2OPF3 TEST

--(a+b)/a
local c = Q.mk_col({2, 2, 2}, "I4")

local dmas1_result = Q.vvdiv(Q.vvadd(a, b, { junk = "junk" }), a, { junk = "junk" })
dmas1_result:eval()
assert(type(dmas1_result) == "lVector")

--print("##########")
local cmp_result = Q.vveq(dmas1_result, c)
cmp_result:eval()
assert(type(cmp_result) == "lVector")

local n1 = Q.sum(cmp_result):eval()
print(n1)
print(a:length())
assert(n1 == a:length())
assert(n1 == b:length())
assert(n1 == c:length())

Q.print_csv(dmas1_result, nil, "")
print("F1F2OPF3 dmas Test 1 DONE !!")
print("------------------------------------------")

end
--======================================
-- a + b/a
tests.t2 = function ()

local d = Q.mk_col({2, 3, 4}, "I4")

local dmas2_result = Q.vvadd(a, Q.vvdiv(b, a, { junk = "junk" }), { junk = "junk" })
dmas2_result:eval()
assert(type(dmas2_result) == "lVector")

--print("##########")
local cmp_result = Q.vveq(dmas2_result, d)
cmp_result:eval()
assert(type(cmp_result) == "lVector")

local dmas2 = Q.sum(cmp_result)
assert(dmas2:eval() == a:length())
assert(dmas2:eval() == b:length())
assert(dmas2:eval() == d:length())

Q.print_csv(dmas2_result, nil, "")
print("F1F2OPF3 dmas Test 2 DONE !!")
print("------------------------------------------")
os.execute("rm _*.bin") 
end
--======================================
return tests

