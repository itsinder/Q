-- luajit q_testrunner.lua $HOME/WORK/Q/TESTS/functional_test_cases/test_where_rand.lua
-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local tests = {}

local a = Q.rand( { lb = 10, ub = 25, qtype = "F4", len = 10 })
a:eval()
Q.print_csv(a, nil, "")

tests.t1 = function ()

local b = Q.mk_col({1, 0, 0, 1, 0, 1, 1, 0, 0, 0}, "B1")


--local out_table = {10, 40}

local c = Q.where(a, b)
c:eval()

assert(c:length() == Q.sum(b):eval(), "Length Mismatch")


print("=======================================")
end
--======================================
tests.t2 = function ()

local b = Q.mk_col({1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, "B1")

local c = Q.where(a, b)
c:eval()

assert(Q.sum(a):eval() == Q.sum(c):eval(), "Sum Mismatch")
assert(Q.min(a):eval() == Q.min(c):eval(), "Min Mismatch")
assert(Q.max(a):eval() == Q.max(c):eval(), "Max Mismatch")
print("=======================================")
end
--======================================
tests.t3 = function ()
-- Expected data sample space
local q = Q.mk_col({97.4, 94, 99.3, 92.5 }, "F4")
-- Collected data sample space
local p = Q.mk_col({87.3, 99.6, 99, 10, 92.5, 50, 99.3, 97.4, 90, 95}, "F4")
-- Mapping data collected on expected
local r = Q.ainb(p, q)
r:eval()

local s = Q.where(a,r)
s:eval()

assert(s:length() == Q.sum(r):eval(), "Length Mismatch")

print("=======================================")
end
--======================================
return tests







