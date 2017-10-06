-- FUNCTIONAL
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'
c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
c2 = Q.mk_col( {20,35,26,50,11,30,45,17}, "I4")
z = Q.vvadd(c1, c2)
print("calling eval")
z:eval()
status = pcall(Q.sort, c1, "asc")
assert(not status )
Q.sort(z, "asc")
Q.print_csv(z, nil, "")

print("SUCCESS for " .. arg[0])
require 'Q/UTILS/lua/strict'
os.exit()
