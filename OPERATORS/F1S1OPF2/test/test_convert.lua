local Q = require 'Q'

local i1 = Q.mk_col({22100.45, 125.44, 200.8}, "F4")
local c1 = Q.convert(i1, {qtype = "I1"})
c1:eval()
Q.print_csv(c1, nil, "")
--===========================
print("Successfully completed" .. arg[0])
os.exit()
