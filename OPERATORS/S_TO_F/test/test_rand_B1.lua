-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
--========================================
len = 100000
p = 0.25;
actual = Q.sum(Q.rand( { probability = p, qtype = "B1", len = len })):eval()
expected = len * p
print("len,p,actual,expected", len, p, actual, expected)
assert( ( ( actual >= expected * 0.90 ) and
     ( actual <= expected * 1.10 ) ) )
--=======================================
print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
