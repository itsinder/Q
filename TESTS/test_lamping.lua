--[[

Input:
Location        A       G       C       T
x1      1       2       3       4
x2      4       3       2       1

Output:
X1 A 1
X1 G 2
X1 C 3
X1 T 4
X2 A 4
X2 G 3
X2 C 2
X2 T 1
P.S. Here is an example of how to use tidyr and dplyr functions. Suppose you take your input and want to know how many times each base occurs exactly once. Assuming I haven't made a mistake, the R for that is:

starting %>%
  gather(base, count, A, G, C, T) %>%
  filter(count == 1) %>%
  group_by(base) %>%
  summarize(count = n())
--]]

-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}
tests.t1 = function ()
  agct = Q.load_csv("agct.csv")
  for k, v in pairs(agct) do 
    print(v, Q.sum(Q.vveq(x, 1)):eval())
  end
  print("Test t1 passed")
end
return tests
