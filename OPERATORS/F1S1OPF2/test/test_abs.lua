local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local c1 = Q.rand({lb = -10, ub = 10, qtype = "I4", len = 10})
print("-------before into abs value--------")
c1:eval()
Q.print_csv(c1, nil, "")

local c1 = Q.abs(c1)
c1:eval()
print("-------after  abs value--------")
Q.print_csv(c1, nil, "")

local num_lt_0 = Q.sum(Q.vslt(c1, 0)):eval()
print("num_lt_0 = ", num_lt_0)
assert(num_lt_0 == 0, "FAILURE")

print("SUCCESS for abs")
os.exit()
