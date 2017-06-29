local Q = require 'Q'
num = (2048*1048576)-1
local c1 = Q.const( {val = num, qtype = "I4", len = 8 })
c1:eval()
Q.print_csv(c1, nil, "")
os.exit()
