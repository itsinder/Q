local Q = require 'Q'
local logit = require 'Q/ML/LOGISTIC_REGRESSION/lua/logit'

z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 4 } )
z = Q.mk_col({0.5, 0.7, 0.2 , 0.1}, "F8")
y = logit(z)
y:eval()
Q.print_csv(y, nil, "")
