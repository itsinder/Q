local Q = require 'Q'
-- local dbg = require 'Q/UTILS/lua/debugger'
z = Q.const( { val = 5, qtype = "I4", len = 10 })
z:eval()
Q.print_csv(z, nil, "")
--========================================
z = Q.rand( { lb = 10, ub = 20, seed = 1234, qtype = "I4", len = 10 })
z:eval()
Q.print_csv(z, nil, "")
--========================================
z = Q.seq( {start = 2, by = 4, qtype = "I4", len = 10} )
z:eval()
Q.print_csv(z, nil, "")
--========================================
os.exit()
