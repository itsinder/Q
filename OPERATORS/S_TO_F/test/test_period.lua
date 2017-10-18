-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
n = 65537
len = n * 3 
y = Q.period({start = 1, by = 2, period = 3, qtype = "I4", len = len })
x = Q.sum(y):eval()
print(x)
assert(x == (len * (1+3+5)))
-- TODO Krushnakant: Q.print_csv(y, nil, "")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
