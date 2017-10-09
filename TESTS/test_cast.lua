-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
-- this must work because B1 must be multiple of 8 bytes
c1 = Q.mk_col( {1,1,1,1}, "I4")
c2 = Q.cast(c1, "B1")
assert(Q.sum(c2):eval() == 4)
--=========== Note that since we are counting number of bits, same rslt
c1 = Q.mk_col( {2,2,2,2}, "I4")
c2 = Q.cast(c1, "B1")
assert(Q.sum(c2):eval() == 4)
--============================= Now twice as many bits set 
c1 = Q.mk_col( {3,3,3,3}, "I4")
c2 = Q.cast(c1, "B1")
assert(Q.sum(c2):eval() == 8)
--=============================
c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I8")
sum1 = Q.sum(c1):eval()
c2 = Q.cast(c1, "I4")
assert(c2:num_elements() == 16)
sum2 = Q.sum(c2):eval()
assert(sum1 == sum2)
-- let's do some things that should not work
-- this will not work because file size not multiple of element size
c1 = Q.mk_col( {1,2,3}, "I4")
status, c2 = pcall(Q.cast, c1, "F8")
assert(not status)
-- this will not work because B1 must be multiple of 8 bytes
c1 = Q.mk_col( {1,2,3}, "I4")
status, c2 = pcall(Q.cast, c1, "B1")
assert(not status)

print("SUCCESS for " .. arg[0])
require 'Q/UTILS/lua/strict'
os.exit()
