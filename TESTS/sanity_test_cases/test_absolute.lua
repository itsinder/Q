-- SANITY TEST
-- ## Problem: Verifying the sum of opposite vector and the change when abs operator comes into play.
-- ## Using Q.seq & absolute function to solve a problem


-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- Negative Series
a = Q.seq( {start = -100, by = 1, qtype = "I4", len = 100} )

-- Positive Series
b = Q.seq( {start = 1, by = 1, qtype = "I4", len = 100} )

-- Sort a
a:eval()
Q.sort(a, "dsc")

-- Vector Sum of sorted dsc a & b
ab_sum = Q.vvsum(a, b)
ab_sum:eval()
--assert(type(ab_sum) == "lVector")

-- Sum of series
local n1 = Q.sum(ab_sum)
m1 = n1:eval()
print(m1)
-- Expected Outcome
assert(m1 == 0)

--=======================================
-- Apply abs function

local b1 = Q.abs(b)
--b1:eval()

-- Vector Sum
ab_sum = Q.vvsum(a, b)
ab_sum:eval()
assert(type(ab_sum) == "lVector")

-- Sum of series
local n2 = Q.sum(ab_sum2)
m2 = n2:eval()
-- Expected Outcome
assert(m1 == 2*sum_b1)

--=======================================
print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
