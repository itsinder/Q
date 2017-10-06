-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local diff = require 'Q/UTILS/lua/diff'

local b = Q.mk_col({-2, 0, 2, 4 }, "I4")
local a = Q.mk_col({-2, -2, -1, -1, 0, 1, 1, 2, 2, 3, 3}, "I4")
b:eval()
local c = Q.ainb(a, b)
c:eval()
local n = Q.sum(c):eval()
-- TODO assert(n == 6)
Q.print_csv({a, c}, nil, "_out1.txt")
assert(diff("out1.txt", "_out1.txt"))

-- TODO Write one with a much larger A and B vector

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
