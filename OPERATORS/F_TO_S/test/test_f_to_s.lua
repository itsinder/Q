local Q = require 'Q'
-- local dbg = require 'Q/UTILS/lua/debugger'
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
local z = Q.sum(c1)
print(z)
assert(z == 36 )
local z = Q.min(c1)
assert(z == 1 )
local z = Q.max(c1)
assert(z == 8 )
local z = Q.sum_sqr(c1)
assert(z == XXXXX )
--=========================================
os.exit()
