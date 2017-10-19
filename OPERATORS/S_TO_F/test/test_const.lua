-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
num = (2048*1048576)-1
local c1 = Q.const( {val = num, qtype = "I4", len = 8 })
c1:eval()
minval = Q.min(c1):eval()
maxval = Q.max(c1):eval()
assert(minval == num)
assert(maxval == num)

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
