-- SANITY TEST
-- ## Problem: Sum of consecutive natural numbers & its reverse returns a constant array
-- ## Using Q.seq & Q.const to solve a problem

-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- Original Series
a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 1000} )

-- Reverse Series
b = Q.seq( {start = 999, by = -1, qtype = "I4", len = 1000} )

-- Sum of series
c = Q.vvadd(a, b)

-- Expected Outcome
d = Q.const( { val = 1000, qtype = "I4", len = 1000 })

--========================================
local m = Q.sum(Q.vveq(d, c)):eval()
print(m)
assert(m == 1000)
--=======================================

print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
