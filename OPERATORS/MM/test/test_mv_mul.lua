-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local x1 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
local x2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
local X = {x1, x2}
local Y = Q.mk_col({10, 20}, 'F8')
local Z = Q.mv_mul(X, Y)
Z:eval()
print("Completed mv_mul")
Q.print_csv(Z, nil, "")
print("================")
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
