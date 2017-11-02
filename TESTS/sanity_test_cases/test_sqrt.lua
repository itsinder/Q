-- SANITY TEST
-- ## Problem: Square a whole number and then take out its square root, the result must be same.
-- ## Using Q.seq & Q.sqrt to solve a problem

-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- Creating a vector
local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 10} )

-- Creating another vector which is square of the vector a
local b = Q.vvmul(a, a)
Q.print_csv(b:eval(),nil, "")

-- Finding square root of the elements of the series b
local c = Q.sqrt(b)
Q.print_csv(c:eval(),nil, "")


-- Expected Outcome
--========================================
result = Q.vveq(a, c):eval()
Q.print_csv(result,nil, "")
assert(Q.sum(result) == a:length())
--=======================================

print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.execute("rm _*.bin") 
os.exit()
