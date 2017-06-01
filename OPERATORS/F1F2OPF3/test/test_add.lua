local Q = require 'Q'
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
local c2 = Q.mk_col( {8,7,6,5,4,3,2,1}, "I4")
print("---------------------------")
z = Q.vvadd(c1, c2, "junk")
local dbg = require 'Q/UTILS/lua/debugger'
print("xxxxxxxxxxxxxxxxxxxx")
Q.print_csv(z, nil, "")
os.exit()
