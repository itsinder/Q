-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local x1 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
local x2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
local X = {x1, x2}
local Y = Q.mk_col({10, 20}, 'F8')
local Z = Q.mvmul(X, Y)
print("Completed mvmul")
local W = Q.cmvmul(X, Y)
print("Completed cmvmul")
-- x = Q.sum(Q.vveq(z, w))
-- assert(x == x1:length())
Q.print_csv(Z, nil, "")
print("================")
W:eval()
Q.print_csv(W, nil, "")
n = Q.sum(Q.vveq(Z, W))
local numer, denom = n:eval()
assert(numer == x1:length())
assert(numer == denom)
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
