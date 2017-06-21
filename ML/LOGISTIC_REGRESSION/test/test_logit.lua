local Q = require 'Q'
local logit = require 'Q/ML/LOGISTIC_REGRESSION/lua/logit'

z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 3 } )
z:eval()
Q.print_csv(z, nil, "")
