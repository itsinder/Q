-- SANITY TEST
-- ## Problem: Abolute value of negative vector matches its positive version Sum
-- ## Using Q.seq & absolute function to solve a problem


-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- Negative Series
a = Q.seq( {start = -100, by = 1, qtype = "I4", len = 100} )
--a:eval()
-- Positive Series
b = Q.seq( {start = 1, by = 1, qtype = "I4", len = 100} )
--b:eval()

--[[ Q.print_csv(b, nil, "")
print(type(b))
assert(type(b) == "lVector")
x = Q.mk_col({10,50,40,30}, 'I4')
Q.sort(x, "dsc")

Q.print_csv(x, nil, "") ]]--
--[[
sum_b = Q.sum(b)
sum_b1 = sum_b:eval()
print(sum_b1)

-- Vector Sum
ab_sum = Q.vvsum(a, b)
ab_sum:eval()
assert(type(ab_sum) == "lVector")

-- Sum of series
local n1 = Q.sum(ab_sum)
m1 = n1:eval()
print(m1)
-- Expected Outcome
assert(m1 == 0)
]]--
--=======================================
-- Apply abs function

local b1 = Q.abs(b)
--b1:eval()

-- Vector Sum
ab_sum = Q.vvsum(a, b)
ab_sum:eval()
assert(type(ab_sum2) == "lVector")

-- Sum of series
local n2 = Q.sum(ab_sum2)
m2 = n2:eval()
-- Expected Outcome
assert(m1 == 2*sum_b1)

--=======================================
print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
