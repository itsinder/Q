-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
Scalar = require 'libsclr'


-- Create vector 'a' with Q.rand or by Q.seq
a = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, "I4")
-- Create binary vector b through Q.rand
b = Q.mk_col({1, 0, 1, 0, 1, 0, 1, 0, 0, 1}, "B1")
-- s1 = find the sum of 'b'
-- s2 = total length of b minus - s1

sval = Scalar.new("10", "I4")

a:make_nulls(b)
-- s3 = sum of 'a'
c = Q.drop_nulls(a, sval)
c:eval()
-- s4 = sum of c 
assert(Q.sum(c):eval() == 76)
--assert(s4 = s2*scalar + s3)


--[[
local a = Q.rand( { lb = 1, ub = 20, qtype = "I4", len = 10 })
local b = Q.rand( { lb = 0, ub = 1, qtype = "B1", len = 10 })

local s1 = sum(b)
local s2 = 10 - sum(b)

sval = Scalar.new("10", "I4")

a:make_nulls(b)
 
s3 = sum(a)

c = Q.drop_nulls(a, sval)
c:eval()

s4 = sum(c)

assert( s4 = s2*10 + s3)



]]--





--[[
x = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
y = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
sval = Scalar.new("100", "I4")
x:make_nulls(y)

z = Q.drop_nulls(x, sval)
z:eval()
Q.print_csv(z, nil, "")
assert(Q.sum(z):eval() == 316)

]]--

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()

