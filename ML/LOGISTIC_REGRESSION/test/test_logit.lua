require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 4 } )
local x = Q.logit(z)
x:eval()
-- TODO Check values of x 
Q.print_csv(x, nil, "")
print("SUCCESS for " .. arg[0] )
os.exit()
