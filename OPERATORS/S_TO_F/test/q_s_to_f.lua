local Q = require 'Q'
require 'Q/UTILS/lua/strict'
num = (2048*1048576)-1
local c1 = Q.const( {val = num, qtype = "I4", len = 8 })
c1:eval()
-- TODO Compare values against correct ones
Q.print_csv(c1, nil, "")
os.exit()
