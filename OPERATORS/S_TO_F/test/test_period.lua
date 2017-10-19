-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

n = 67
n = 32768
n = 32768+10923
print("n = ", n)
len = n * 3 
y = Q.period({start = 1, by = 2, period = 3, qtype = "I4", len = len })
actual = Q.sum(y):eval()
expected = (n * (1+3+5))
if (actual ~= expected ) then 
  print("FAILURE", actual, expected) 
else
  print("SUCCESS for ", arg[0])
end 
-- TODO Krushnakant: Q.print_csv(y, nil, "")
require('Q/UTILS/lua/cleanup')()
-- os.execute("rm -f _*.bin")
os.exit()