-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
-- local dbg = require 'Q/UTILS/lua/debugger'
z = Q.const( { val = 5, qtype = "I4", len = 10 })
z:eval()
Q.print_csv(z, nil, "")
--========================================
z = Q.rand( { lb = 100, ub = 200, seed = 1234, qtype = "I4", len = 10 })
z:eval()
Q.print_csv(z, nil, "")
--========================================
--z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 3 } )
--z:eval()
--Q.print_csv(z, nil, "")
--========================================
z = Q.seq( {start = -1, by = 5, qtype = "I4", len = 10} )
z:eval()
Q.print_csv(z, nil, "")
--=======================================
print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
