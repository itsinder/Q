-- Scenario based testing
-- ## Problem: Find out how many credit cards have interest rate lower than the search call.
-- ## Using leq & ifxthenyelsez to solve a problem
-- ## Let cc be the list of credit card by name
-- ## comparing the data set, if a > b assign value 1 or else 0.

-- Libraray Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- Data set
--ToDo -- cc = {list of credit cards} 
local cc_ir = Q.rand( { lb = 8, ub = 30, qtype = "F4", len = 10 })
cc_ir:eval()
--Q.print_csv(cc_ir, nil, "")
local exp_ir = Q.const( { val = 14.25, qtype = "F4", len = 10 })
exp_ir:eval()
-- Comparing data sets
local x = Q.vvleq(cc_ir, exp_ir)
x:eval()
Q.print_csv(x, nil, "")

-- value set
local y = Q.const( { val = 1, qtype = 'I4', len = 100} )
y:eval()
local z = Q.const( { val = 0, qtype = 'I4', len = 100} )
z:eval()
-- applying logic
local w = Q.ifxthenyelsez(x, y, z)
w:eval()
--Q.print_csv(w, nil, "")
n = Q.sum(w):eval()

print("Number of credit cards searched whose interest rate percentage is less than 14.25 are", n )

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
