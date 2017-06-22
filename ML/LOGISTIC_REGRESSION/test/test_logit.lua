local Q = require 'Q'
local logit = require 'Q/ML/LOGISTIC_REGRESSION/lua/logit'

-- z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 4 } )
z = Q.mk_col({0.5, 0.7, 0.2 , 0.1, 0.05}, "F8")
z:eval()
x, y = logit(z)
-- y = Q.vsadd(z, 1)
x:eval()
y:eval()
Q.print_csv(x, nil, "")
print("--------")
Q.print_csv(y, nil, "")
print("Successfully completed " .. arg[0] )
os.exit()
