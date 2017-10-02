-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
Scalar = require 'libsclr' ; 

x = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
y = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
sval = Scalar.new("100", "I4")
x:make_nulls(y)
z = Q.drop_nulls(x, sval)

assert(Q.sum(z):eval() == 316)

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()

