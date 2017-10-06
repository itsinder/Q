-- Scenario based testing
-- ## Problem: If data elelment in set greater than elements in set b
-- ## Using geq & ifxthenyelsez to solve a problem
-- ## Let a and b be data set
-- ## comparing the data set, if a > b assign value 1 or else 0.

-- Libraray Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
-- Data set
local a = Q.rand( { lb = 10, ub = 20, qtype = "I4", len = 10 })
a:eval()
--Q.print_csv(a, nil, "")
local b = Q.rand( { lb = 10, ub = 20, qtype = "I4", len = 10 })
b:eval()
--Q.print_csv(b, nil, "")

-- Comparing data sets
x = Q.vvgeq(a, b)
x:eval()
--Q.print_csv(x, nil, "")

-- value set
local y = Q.const( { val = 1, qtype = 'I4', len = 10} )
y:eval()
local z = Q.const( { val = 0, qtype = 'I4', len = 10} )
z:eval()
-- applying logic
local w = Q.ifxthenyelsez(x, y, z)
w:eval()


print("Number of elements in data set 'a' greater than in data set 'b' is", Q.sum(w):eval())

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
