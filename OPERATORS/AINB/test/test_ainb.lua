-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local b = Q.mk_col({1, 2, 3, 4}, "I4")
local a = Q.mk_col({-2, -2, -1, -1, 0, 1, 1, 2, 2, 3, 3}, "I4")
b:eval()
local c = Q.ainb(a, b)
c:eval()
local n = Q.sum(c):eval()
assert(n == 6)

-- TODO Write one with a much larger A and B vector

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
