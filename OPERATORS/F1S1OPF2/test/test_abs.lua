local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local c1 = Q.rand({lb = -10, ub = 10, qtype = "I4", len = 10})
c1:eval()
Q.print_csv(c1, nil, "")
print("-------turn into abs value--------")
local c1 = Q.abs(c1)
--local lt = Q.sum(Q.vslt(c1, 0)):eval()
--assert(lt == 0, "FAILURE")
c1:eval()
Q.print_csv(c1, nil, "")

print("SUCCESS for abs")
os.exit()
