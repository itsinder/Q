-- Sanity test cases. Behaviour of eval function & its requirement.
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

-- case 1: When mk_col is used, local or global, eval is not required to print
local a = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
Q.print_csv(a, nil, "")

-- case 2: When Q.const is used, local or global, eval is required to print
b = Q.const( { val = 100, qtype = 'I4', len = 10} )
b:eval()
Q.print_csv(b, nil, "")

-- case 3: When Q.rand is used, local or global, eval is required to print
c = Q.rand( { lb = 1, ub = 20, qtype = "I4", len = 100 })
c:eval()
Q.print_csv(c, nil, "")

-- case 4: When Q.seq is used, local or global, eval is required to print
e = Q.seq( {start = 1, by = 1, qtype = "I4", len = 100} )
e:eval()
Q.print_csv(e, nil, "")

-- case 5: When addition or some other operation is done, eval is required.
local x = Q.mk_col({1, 2, 3}, "I4")
local y = Q.mk_col({1, 2, 3}, "I4")

-- ADD
local f = Q.vvadd(x, y, { junk = "junk" })
f:eval()
Q.print_csv(f, nil, "")

-- case 6: When a complete vector is sorted, eval is not required to print.
local g = Q.mk_col({1, 3, 2}, "I4")
Q.sort(g, "asc")
--g:eval()
Q.print_csv(g, nil, "")

print("Sanity div Test DONE !!")
print("------------------------------------------")

print("SUCCESS for " .. arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()



