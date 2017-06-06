local Q = require 'Q'
-- local dbg = require 'Q/UTILS/lua/debugger'
z = Q.const( { val = 5, qtype = "I4", len = 10 })
z:eval()
Q.print_csv(z, nil, "")
--========================================
os.exit()
