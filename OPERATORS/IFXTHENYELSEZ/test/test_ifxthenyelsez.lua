-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
local y = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
local z = Q.mk_col({-1, -2, -3, -4, -5, -6, -7}, "I4")
local exp_w = Q.mk_col({1, -2, 3, -4, 5, -6, 7}, "I4")
local w = Q.ifxthenyelsez(x, y, z)
w:eval()
local n = Q.sum(Q.vveq(w, exp_w))
assert(n == 4)

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
