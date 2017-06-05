local Q = require 'Q'
local c1 = Q.const( {val = 10, qtype = "I4", len = "8" })
c1:eval()
Q.print_csv(c1, nil, "")
os.exit()
