-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
Scalar = require 'libsclr'


-- Create vector 'a' with Q.rand or by Q.seq
local a = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, "I4")
-- Create binary vector b through Q.rand
local b = Q.mk_col({1, 0, 1, 0, 1, 0, 1, 0, 0, 1}, "B1")
-- s1 = find the sum of 'b'
--local s1 = Q.sum(b):eval()
--print(s1)
-- s2 = total length of b minus - s1
--local s2 = 10 - s1
--print(s2)

sval = Scalar.new("10", "I4")

a:make_nulls(b)
-- s3 = sum of 'a'
--local s3 = Q.sum(a):eval()
--print(s3)
c = Q.drop_nulls(a, sval)
-- s4 = sum of c 
local s4 = Q.sum(c):eval()
print(s4)
assert(Q.sum(c):eval() == 76)
--assert(s4 = s2*scalar + s3)

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()

